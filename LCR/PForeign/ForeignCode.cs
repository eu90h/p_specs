using System;
using System.Runtime;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using Plang.CSharpRuntime;
using Plang.CSharpRuntime.Values;
using Plang.CSharpRuntime.Exceptions;
using System.Threading;
using System.Threading.Tasks;
using System.Security.Cryptography;

#pragma warning disable 162, 219, 414
namespace PImplementation
{
  public static partial class GlobalFunctions
  {
    public static int RandomID(PMachine pMachine)
    {
      using (RNGCryptoServiceProvider rg = new RNGCryptoServiceProvider()) 
      { 
        byte[] rno = new byte[5];    
        rg.GetBytes(rno);    
        int randomvalue = BitConverter.ToInt32(rno, 0);
        return randomvalue > 0 ? randomvalue : -1 * randomvalue;
      }
    }
  }
}