using System;
using System.Collections;
using System.Collections.Generic;
using PTMCommon;
using PTMDAL;

namespace PTMBAL
{
    public interface IBLCheckPayee
    {
       /// <summary>
        /// Returns payee information whose satatus='Active' for supplied payeeID from check_payee table .
        /// </summary>
        CheckPayeeModel GetPayeeDetails(string payeeID, string status="Active");

        /// <summary>
        /// Inserts a record into check_Payee table
        /// </summary>
        bool CheckPayeeInsert(CheckPayeeModel model);

        /// <summary>
        /// Update a record in check_Payee table
        /// </summary>
        bool CheckPayeeUpdate(CheckPayeeModel model);

        /// <summary>
        /// Deletes record from Check_payee table by Payee_ID
        /// </summary>
        bool CheckPayeeDelete(string payeeId);

        AgencyIDModel GetPayee(string payeeId, IDBAPayee dbPayee = null);

        void SendChangeAlert(CheckPayeeModel model, IList<string> fieldsChanged, Guid correlationId);
    }
}
