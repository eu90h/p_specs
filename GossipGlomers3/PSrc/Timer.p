/*****************************************************************************************
The timer state machine models the non-deterministic behavior of an OS timer
******************************************************************************************/
machine Timer
{
  // user of the timer
  var client: machine;
  var value: tGossip;

  start state Init {
    entry (payload : (client : machine, value : tGossip)){
      client = payload.client;
      value = payload.value;
      goto WaitForTimerRequests;
    }
  }

  state WaitForTimerRequests {
    on eStartTimer goto TimerStarted;
    ignore eCancelTimer, eDelayedTimeOut;
  }

  state TimerStarted {
    defer eStartTimer;
    entry {
      if($)
      {
        send client, eTimeOut, value;
        goto WaitForTimerRequests;
      }
      else
      {
        send this, eDelayedTimeOut;
      }
    }
    on eDelayedTimeOut goto TimerStarted;
    on eCancelTimer goto WaitForTimerRequests;
  }
}

/************************************************
Events used to interact with the timer machine
************************************************/
event eStartTimer;
event eCancelTimer;
event eTimeOut : tGossip;
event eDelayedTimeOut;
/************************************************
Functions or API's to interact with the OS Timer
*************************************************/
// create timer
fun CreateTimer(client: machine, value : tGossip) : Timer
{
  return new Timer((client = client, value = value));
}

// start timer
fun StartTimer(timer: Timer)
{
  send timer, eStartTimer;
}

// cancel timer
fun CancelTimer(timer: Timer)
{
  send timer, eCancelTimer;
}

module Timer = {Timer};