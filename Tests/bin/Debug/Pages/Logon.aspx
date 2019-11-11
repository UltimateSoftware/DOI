<%@ Page language="c#" Codebehind="Logon.aspx.cs" AutoEventWireup="false" Inherits="TaxHub.Ssrs.Extensions.Logon,TaxHub.Ssrs.Extensions" Culture="auto" UICulture="auto" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
   <HEAD>
      <title>UltiPro Tax Engine Reports</title>
   </HEAD>
   <body MS_POSITIONING="GridLayout">
      <form id="Form1" method="post" runat="server">
         <asp:Label id="LblUser" style="Z-INDEX: 101; LEFT: 176px; POSITION: absolute; TOP: 152px" runat="server"
            Width="96px" Font-Size="X-Small" Font-Names="Verdana" Font-Bold="True">UserName:</asp:Label>
         <asp:Button id="BtnLogon" style="Z-INDEX: 106; LEFT: 352px; POSITION: absolute; TOP: 224px"
            runat="server" Width="104px" Text="Logon" tabIndex="3"></asp:Button>
         <asp:TextBox id="TxtPwd" style="Z-INDEX: 103; LEFT: 296px; POSITION: absolute; TOP: 184px" runat="server"
            tabIndex="2" Width="160px" TextMode="Password"></asp:TextBox>
         <asp:Label id="LblPwd" style="Z-INDEX: 102; LEFT: 176px; POSITION: absolute; TOP: 192px" runat="server"
            Width="96px" Font-Size="X-Small" Font-Names="Verdana" Font-Bold="True">Password:</asp:Label>&nbsp;
         <asp:TextBox id="TxtUser" style="Z-INDEX: 104; LEFT: 296px; POSITION: absolute; TOP: 152px" runat="server"
            tabIndex="1" Width="160px"></asp:TextBox>
         <asp:Label id="LblMessage" style="Z-INDEX: 107; LEFT: 168px; POSITION: absolute; TOP: 272px"
            runat="server" Width="321px"></asp:Label>
         <asp:Label id="Label1" style="Z-INDEX: 108; LEFT: 120px; POSITION: absolute; TOP: 96px" runat="server"
            Width="416px" Height="32px" Font-Size="Medium" Font-Names="Verdana" Text="UltiPro Tax Engine Reports"></asp:Label>
      </form>
   </body>
</HTML>