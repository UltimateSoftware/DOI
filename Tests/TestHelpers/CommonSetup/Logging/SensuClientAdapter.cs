using System;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using Newtonsoft.Json;
using DDI.Tests.Integration.TestHelpers.CommonSetup.Hosting;

namespace DDI.Tests.Integration.TestHelpers.CommonSetup.Logging
{
    /// <summary>
    /// Class provides connectivity over TCP to the Sense client locally installed on a server.
    /// </summary>
    public class SensuClientAdapter : IDisposable
    {
        private readonly object tcpClientLock = new object();
        private TcpClient client;
        private const string Host = "localhost";
        private const int Port = 3030;

        // ManualResetEvent instances signal completion.
        private readonly ManualResetEvent sendDone;

        private readonly ManualResetEvent receiveDone;

        private readonly ManualResetEvent connectDone;

        /// <summary>
        /// Default constructor.
        /// </summary>
        public SensuClientAdapter()
        {
            this.sendDone = new ManualResetEvent(false);
            this.receiveDone = new ManualResetEvent(false);
            this.connectDone = new ManualResetEvent(false);
            this.client = new TcpClient();
            this.client.BeginConnect(Host, Port, new AsyncCallback(this.ConnectCallback), this.client.Client);
            this.connectDone.WaitOne();
        }

        /// <summary>
        /// Method sends a Sensu alert.
        /// </summary>
        /// <remarks>The Sensu client can perform at 16ms per alert (~60 alerts/sec), keep this information designing the application.</remarks>
        /// <param name="alert">The alert.</param>
        /// <returns>Returns boolean indicator of success.</returns>
        public bool SendAlert(SensuAlert alert)
        {
            Convention.ThrowIfNull(alert, nameof(alert));

            if (this.client == null)
            {
                throw new Exception("Cannot send an alert because TCP client has been disposed or failed to initialize.");
            }

            // reconnect if we lose connection
            if (!this.client.Connected)
            {
                lock (this.tcpClientLock)
                {
                    // We're duplicating this logic after the lock on purpose
                    // this can help prevent deadlocks
                    if (!this.client.Connected)
                    {
                        try
                        {
                            this.client.Close();
                        }
                        catch
                        {
                            //swallow this on purpose -- Will R.
                        }

                        try
                        {
                            // try reconnecting
                            this.client = new TcpClient();
                            this.client.BeginConnect(Host, Port, new AsyncCallback(this.ReconnectCallback), this.client.Client);
                            this.connectDone.WaitOne();
                        }
                        catch (SocketException)
                        {
                            // we can't reconnect to sensu, return false and try again on next connection
                            return false;
                        }
                        catch (ObjectDisposedException)
                        {
                            // we can't reconnect to sensu, return false and try again on next connection
                            return false;
                        }
                    }
                }
            }

            string json = JsonConvert.SerializeObject(alert);

            this.sendDone.Reset();
            this.Send(this.client.Client, json);
            this.sendDone.WaitOne(5000);

            SensuClientState state = new SensuClientState();
            this.receiveDone.Reset();
            this.Receive(this.client.Client, state);
            this.receiveDone.WaitOne(5000);

            string response = state.Response.ToString();
            if (string.Compare(response, "ok", StringComparison.CurrentCultureIgnoreCase) == 0)
            {
                return true;
            }
            else if (string.Compare(response, "invalid", StringComparison.CurrentCultureIgnoreCase) == 0)
            {
                return false;
            }
            else
            {
                throw new Exception("Unknown response is received from the Sensu local client: " + response);
            }
        }

        /// <summary>
        /// Callback for reconnecting if we lose connection to
        /// sensu.
        /// </summary>
        /// <param name="ar">IAsyncResult</param>
        private void ReconnectCallback(IAsyncResult ar)
        {
            try
            {
                this.ConnectCallback(ar);
            }
            catch (SocketException)
            {
                // we want to swallow this. If the reconnect fails we don't
                // want to bring the app down. We should try to reconnect 
                // on the next attempt
            }
            catch (ObjectDisposedException)
            {
                // we want to swallow this. If the reconnect fails we don't
                // want to bring the app down. We should try to reconnect 
                // on the next attempt
            }
        }

        private void ConnectCallback(IAsyncResult ar)
        {
            Socket socket = (Socket)ar.AsyncState;
            socket.EndConnect(ar);
            this.connectDone.Set();
        }

        private void Send(Socket socket, string data)
        {
            byte[] byteData = Encoding.Default.GetBytes(data);

            socket.BeginSend(byteData, 0, byteData.Length, 0, new AsyncCallback(this.SendCallback), socket);
        }

        private void SendCallback(IAsyncResult ar)
        {
            Socket socket = (Socket)ar.AsyncState;
            int bytesSent = socket.EndSend(ar);

            //Debug.WriteLine("Sent: {0} bytes", bytesSent);
            this.sendDone.Set();
        }

        private void Receive(Socket socket, SensuClientState state)
        {
            state.Socket = socket;
            socket.BeginReceive(state.ReceivedBuffer, 0, SensuClientState.BufferSize, 0, new AsyncCallback(this.ReceiveCallback), state);
        }

        private void ReceiveCallback(IAsyncResult ar)
        {
            SensuClientState state = (SensuClientState)ar.AsyncState;
            Socket socket = state.Socket;

            int bytesRead = socket.EndReceive(ar);

            //Debug.WriteLine("Received: {0} bytes", bytesRead);
            if (bytesRead > 0)
            {
                state.Response.Append(Encoding.Default.GetString(state.ReceivedBuffer, 0, bytesRead));

                //Debug.WriteLine("Received text: {0}<EOM>", state.Response.ToString());
                if (bytesRead == SensuClientState.BufferSize)
                {
                    socket.BeginReceive(state.ReceivedBuffer, 0, SensuClientState.BufferSize, 0, new AsyncCallback(this.ReceiveCallback), state);
                    return;
                }
            }

            this.receiveDone.Set();
        }

        /// <summary>
        /// Method disposes any resources used by the class.
        /// </summary>
        public void Dispose()
        {
            this.Dispose(true);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (this.client != null)
            {
                this.client.Close();
                this.client = null;
            }

            if (this.sendDone != null)
            {
                this.sendDone.Dispose();
            }

            if (this.receiveDone != null)
            {
                this.receiveDone.Dispose();
            }

            if (this.connectDone != null)
            {
                this.connectDone.Dispose();
            }
        }
    }

    /// <summary>
    /// Sensu client state object used by an adapter.
    /// </summary>
    internal class SensuClientState
    {
        public const int BufferSize = 256;

        public Socket Socket { get; set; }

        public byte[] ReceivedBuffer { get; set; }

        public StringBuilder Response { get; set; }

        public SensuClientState()
        {
            this.ReceivedBuffer = new byte[BufferSize];
            this.Response = new StringBuilder(string.Empty);
        }
    }
}
