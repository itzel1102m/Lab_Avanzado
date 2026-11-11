/*
*
* ps35.h
* created:      25.02.2009  alex
* last change:  30.05.2019  alex
*
*/

#pragma once

#ifndef __MYPS35
#define __MYPS35


#ifdef __cplusplus
extern "C" {
#endif

// System
long    __stdcall PS35_Connect (long,long,long,long,long,long,long,long);
long    __stdcall PS35_SimpleConnect (long, const char*);
long    __stdcall PS35_Disconnect (long);
long    __stdcall PS35_GetConnectInfo (long,char*,long,long);
long    __stdcall PS35_GetMessage (long,char*,long);
long    __stdcall PS35_GetTerminal (long);
long    __stdcall PS35_SetTerminal (long,long);
long    __stdcall PS35_GetBoardVersion (long,char*,long);
long    __stdcall PS35_GetDriveVersion (long,long,char*,long);
long    __stdcall PS35_GetSerNumber (long,char*,long);
long    __stdcall PS35_GetError (long);
long    __stdcall PS35_CheckMem (long);
long    __stdcall PS35_ResetBoard (long);
long    __stdcall PS35_ResetDrives (long);
long    __stdcall PS35_ClearError (long);

// Operate
long    __stdcall PS35_MotorInit (long,long);
long    __stdcall PS35_MotorOn (long,long);
long    __stdcall PS35_MotorOff (long,long);
long    __stdcall PS35_GetTargetMode (long,long);
long    __stdcall PS35_SetTargetMode (long,long,long);
long    __stdcall PS35_GetPosMode (long,long);
long    __stdcall PS35_SetPosMode (long,long,long);
long    __stdcall PS35_GetPosition (long,long);
long    __stdcall PS35_SetPosition (long,long,long);
long    __stdcall PS35_ResetCounter (long,long);
long    __stdcall PS35_GetTarget (long,long);
long    __stdcall PS35_SetTarget (long,long,long);
long    __stdcall PS35_GoTarget (long,long);
long    __stdcall PS35_GoRef (long,long,long);
long    __stdcall PS35_FreeSwitch (long,long);
long    __stdcall PS35_Stop (long,long);
long    __stdcall PS35_GoVel (long,long);
long    __stdcall PS35_StopVel (long,long);
long    __stdcall PS35_GetMotorType (long,long);
long    __stdcall PS35_SetMotorType (long,long,long);
long    __stdcall PS35_GetAxisReleased (long,long);
long    __stdcall PS35_SetAxisReleased (long,long,long);
long    __stdcall PS35_GetMotorCommCounts (long,long);
long    __stdcall PS35_SetMotorCommCounts (long,long,long);
long    __stdcall PS35_GetEncLines (long,long);
long    __stdcall PS35_SetEncLines (long,long,long);
long    __stdcall PS35_GetMotorPoles (long,long);
long    __stdcall PS35_SetMotorPoles (long,long,long);
long    __stdcall PS35_GetAxisMonitor (long,long);
long    __stdcall PS35_SetAxisMonitor (long,long,long);
long    __stdcall PS35_GetAxisState (long,long);
long    __stdcall PS35_GetMoveState (long,long);
long    __stdcall PS35_GetVelState (long,long);
long    __stdcall PS35_GetErrorState (long,long);
long    __stdcall PS35_GetRefReady (long,long);
long    __stdcall PS35_GetActVel (long,long);
long    __stdcall PS35_GetEncPos (long,long);
long    __stdcall PS35_GetPosError (long,long);
long    __stdcall PS35_GetMaxPosError (long,long);
long    __stdcall PS35_SetMaxPosError (long,long,long);
long    __stdcall PS35_MultiGoTarget (long,long,long);
long    __stdcall PS35_GetVectorTabRow (long,long,char*,long);
long    __stdcall PS35_SetVectorTabRow (long,long,const char*);
long    __stdcall PS35_CopyVectorTab (long,long,long,long);
long    __stdcall PS35_ClearVectorTab (long,long,long);
long    __stdcall PS35_GoVectorTab (long,long,long);
long    __stdcall PS35_StopVectorTab (long);
long    __stdcall PS35_CheckVectorTab (long,long,long);
long    __stdcall PS35_CircleToVectorTab (long,long,const char*);
long    __stdcall PS35_ChangeTarget (long,long,long);
long    __stdcall PS35_GetPIDTarget (long,long);
long    __stdcall PS35_GetDispFacZ (long,long);
long    __stdcall PS35_SetDispFacZ (long,long,long);
long    __stdcall PS35_GetDispFacN (long,long);
long    __stdcall PS35_SetDispFacN (long,long,long);
long    __stdcall PS35_GetDispMode (long,long);
long    __stdcall PS35_SetDispMode (long,long,long);
long    __stdcall PS35_GetDispPos (long,long);
long    __stdcall PS35_SetDispPos (long,long,long);
long    __stdcall PS35_GetPosRange (long,long);
double  __stdcall PS35_GetActF (long,long);

// Adjustments
long    __stdcall PS35_SaveGlobParams (long);
long    __stdcall PS35_LoadGlobParams (long);
long    __stdcall PS35_SaveAxisParams (long,long);
long    __stdcall PS35_LoadAxisParams (long,long);
long    __stdcall PS35_GetAccel (long,long);
long    __stdcall PS35_SetAccel (long,long,long);
long    __stdcall PS35_GetDecel (long,long);
long    __stdcall PS35_SetDecel (long,long,long);
long    __stdcall PS35_GetJerk (long,long);
long    __stdcall PS35_SetJerk (long,long,long);
long    __stdcall PS35_GetBrakeDecel (long,long);
long    __stdcall PS35_SetBrakeDecel (long,long,long);
long    __stdcall PS35_GetRefDecel (long,long);
long    __stdcall PS35_SetRefDecel (long,long,long);
long    __stdcall PS35_GetPosVel (long,long);
long    __stdcall PS35_SetPosVel (long,long,long);
long    __stdcall PS35_GetVel (long,long);
long    __stdcall PS35_SetVel (long,long,long);
long    __stdcall PS35_GetSlowRefVel (long,long);
long    __stdcall PS35_SetSlowRefVel (long,long,long);
long    __stdcall PS35_GetFastRefVel (long,long);
long    __stdcall PS35_SetFastRefVel (long,long,long);
long    __stdcall PS35_GetFreeVel (long,long);
long    __stdcall PS35_SetFreeVel (long,long,long);
long    __stdcall PS35_GetMicrostepMode (long,long);
long    __stdcall PS35_SetMicrostepMode (long,long,long);
long    __stdcall PS35_GetDriveCurrent (long,long);
long    __stdcall PS35_SetDriveCurrent (long,long,long);
long    __stdcall PS35_GetHoldCurrent (long,long);
long    __stdcall PS35_SetHoldCurrent (long,long,long);
long    __stdcall PS35_GetPhaseInitTime (long,long);
long    __stdcall PS35_SetPhaseInitTime (long,long,long);
long    __stdcall PS35_GetPhaseInitAmp (long,long);
long    __stdcall PS35_SetPhaseInitAmp (long,long,long);
long    __stdcall PS35_GetPhasePwmFreq (long,long);
long    __stdcall PS35_SetPhasePwmFreq (long,long,long);
long    __stdcall PS35_GetCurrentLevel (long,long);
long    __stdcall PS35_SetCurrentLevel (long,long,long);
long    __stdcall PS35_GetServoLoopMax (long,long);
long    __stdcall PS35_SetServoLoopMax (long,long,long);
long    __stdcall PS35_GetVectorVel (long,long);
long    __stdcall PS35_SetVectorVel (long,long,long);
long    __stdcall PS35_GetVectorAccel (long,long);
long    __stdcall PS35_SetVectorAccel (long,long,long);
double  __stdcall PS35_GetPosF (long,long);
long    __stdcall PS35_SetPosF (long,long,double);
double  __stdcall PS35_GetF (long,long);
long    __stdcall PS35_SetF (long,long,double);
double  __stdcall PS35_GetSlowRefF (long,long);
long    __stdcall PS35_SetSlowRefF (long,long,double);
double  __stdcall PS35_GetFastRefF (long,long);
long    __stdcall PS35_SetFastRefF (long,long,double);
double  __stdcall PS35_GetFreeF (long,long);
long    __stdcall PS35_SetFreeF (long,long,double);
double  __stdcall PS35_GetVectorF (long,long);
long    __stdcall PS35_SetVectorF (long,long,double);

// Software/hardware regulator
long    __stdcall PS35_GetSampleTime (long,long);
long    __stdcall PS35_SetSampleTime (long,long,long);
long    __stdcall PS35_GetKP (long,long);
long    __stdcall PS35_SetKP (long,long,long);
long    __stdcall PS35_GetKI (long,long);
long    __stdcall PS35_SetKI (long,long,long);
long    __stdcall PS35_GetKD (long,long);
long    __stdcall PS35_SetKD (long,long,long);
long    __stdcall PS35_GetDTime (long,long);
long    __stdcall PS35_SetDTime (long,long,long);
long    __stdcall PS35_GetILimit (long,long);
long    __stdcall PS35_SetILimit (long,long,long);
long    __stdcall PS35_GetInPosMode (long,long);
long    __stdcall PS35_SetInPosMode (long,long,long);
long    __stdcall PS35_GetInPosTime (long,long);
long    __stdcall PS35_SetInPosTime (long,long,long);
long    __stdcall PS35_GetTargetWindow (long,long);
long    __stdcall PS35_SetTargetWindow (long,long,long);

// Hardware/software switches
long    __stdcall PS35_GetLimitSwitch (long,long);
long    __stdcall PS35_SetLimitSwitch (long,long,long);
long    __stdcall PS35_GetLimitSwitchMode (long,long);
long    __stdcall PS35_SetLimitSwitchMode (long,long,long);
long    __stdcall PS35_GetRefSwitch (long,long);
long    __stdcall PS35_SetRefSwitch (long,long,long);
long    __stdcall PS35_GetRefSwitchMode (long,long);
long    __stdcall PS35_SetRefSwitchMode (long,long,long);
long    __stdcall PS35_GetSwitchState (long,long);
long    __stdcall PS35_GetSwitchHyst (long,long);
long    __stdcall PS35_GetLimitControl (long,long);
long    __stdcall PS35_SetLimitControl (long,long,long);
long    __stdcall PS35_GetLimitMin (long,long);
long    __stdcall PS35_SetLimitMin (long,long,long);
long    __stdcall PS35_GetLimitMax (long,long);
long    __stdcall PS35_SetLimitMax (long,long,long);
long    __stdcall PS35_GetLimitState (long,long);

// Joystick
long    __stdcall PS35_GetJoyX (long);
long    __stdcall PS35_SetJoyX (long,long);
long    __stdcall PS35_GetJoyY (long);
long    __stdcall PS35_SetJoyY (long,long);
long    __stdcall PS35_GetJoyZ (long);
long    __stdcall PS35_SetJoyZ (long,long);
long    __stdcall PS35_JoystickOn (long);
long    __stdcall PS35_JoystickOff (long);
long    __stdcall PS35_GetJoyVel (long,long);
long    __stdcall PS35_SetJoyVel (long,long,long);
long    __stdcall PS35_GetJoyAccel (long,long);
long    __stdcall PS35_SetJoyAccel (long,long,long);
long    __stdcall PS35_GetJoyZone (long);
long    __stdcall PS35_SetJoyZone (long,long);
long    __stdcall PS35_GetJoyZeroX (long);
long    __stdcall PS35_SetJoyZeroX (long,long);
long    __stdcall PS35_GetJoyZeroY (long);
long    __stdcall PS35_SetJoyZeroY (long,long);
long    __stdcall PS35_GetJoyZeroZ (long);
long    __stdcall PS35_SetJoyZeroZ (long,long);
long    __stdcall PS35_GetJoyButton (long);
long    __stdcall PS35_SetJoyButton (long,long);
double  __stdcall PS35_GetJoyF (long,long);
long    __stdcall PS35_SetJoyF (long,long,double);

// Analog & digital I/O
long    __stdcall PS35_GetAxisSignals (long,long);
long    __stdcall PS35_GetAxisIn (long,long);
long    __stdcall PS35_GetAxisOut (long,long);
long    __stdcall PS35_SetAxisOut (long,long,long);
long    __stdcall PS35_GetDigitalInput (long,long);
long    __stdcall PS35_GetDigInTTL (long,long);
long    __stdcall PS35_GetDigitalOutput (long,long);
long    __stdcall PS35_SetDigitalOutput (long,long,long);
long    __stdcall PS35_GetDigOutTTL (long,long);
long    __stdcall PS35_SetDigOutTTL (long,long,long);
long    __stdcall PS35_GetAnalogInput (long,long);
long    __stdcall PS35_GetPwmOutput (long,long);
long    __stdcall PS35_SetPwmOutput (long,long,long);
long    __stdcall PS35_GetPwmBrake (long,long);
long    __stdcall PS35_SetPwmBrake (long,long,long);
long    __stdcall PS35_GetPwmBrakeValue1 (long,long);
long    __stdcall PS35_SetPwmBrakeValue1 (long,long,long);
long    __stdcall PS35_GetPwmBrakeValue2 (long,long);
long    __stdcall PS35_SetPwmBrakeValue2 (long,long,long);
long    __stdcall PS35_GetPwmBrakeTime (long,long);
long    __stdcall PS35_SetPwmBrakeTime (long,long,long);
long    __stdcall PS35_SetPowerOutput (long,long,long);
long    __stdcall PS35_ResetPowerOutput (long,long,long);
long    __stdcall PS35_SetServoPowerDecay (long,long,long);
long    __stdcall PS35_SetStepperPowerDecay (long,long,long);
long    __stdcall PS35_GetEmergencyInput (long);

// Stand-Alone-Compiler/Memory
long    __stdcall PS35_GetMem (long,long); // 1 byte
long    __stdcall PS35_SetMem (long,long,long); // 1 byte
long    __stdcall PS35_GetMem16 (long,long); // 2 bytes
long    __stdcall PS35_SetMem16 (long,long,long); // 2 bytes
long    __stdcall PS35_GetMem32 (long,long); // 4 bytes
long    __stdcall PS35_SetMem32 (long,long,long); // 4 bytes

// Extended functions
long    __stdcall PS35_SetStageAttributes (long,long,double,long,double);
long    __stdcall PS35_SetCalcResol (long,long,double);
double  __stdcall PS35_GetPositionEx (long,long);
long    __stdcall PS35_SetPositionEx (long,long,double);
double  __stdcall PS35_GetTargetEx (long,long);
long    __stdcall PS35_SetTargetEx (long,long,double);
long    __stdcall PS35_ChangeTargetEx (long,long,double);
double  __stdcall PS35_GetPIDTargetEx (long,long);
double  __stdcall PS35_GetPosRangeEx (long,long);
double  __stdcall PS35_GetEncPosEx (long,long);
double  __stdcall PS35_GetLimitMinEx (long,long);
long    __stdcall PS35_SetLimitMinEx (long,long,double);
double  __stdcall PS35_GetLimitMaxEx (long,long);
long    __stdcall PS35_SetLimitMaxEx (long,long,double);
long    __stdcall PS35_MoveEx (long,long,double,long);
long    __stdcall PS35_MoveTriggerEx (long,long,long,long);
long    __stdcall PS35_MoveAnalogInputEx (long,long,long,double,long);
double  __stdcall PS35_GetPosFEx (long,long);
long    __stdcall PS35_SetPosFEx (long,long,double);
double  __stdcall PS35_GetFEx (long,long);
long    __stdcall PS35_SetFEx (long,long,double);
double  __stdcall PS35_GetSlowRefFEx (long,long);
long    __stdcall PS35_SetSlowRefFEx (long,long,double);
double  __stdcall PS35_GetFastRefFEx (long,long);
long    __stdcall PS35_SetFastRefFEx (long,long,double);
double  __stdcall PS35_GetFreeFEx (long,long);
long    __stdcall PS35_SetFreeFEx (long,long,double);
double  __stdcall PS35_GetJoyFEx (long,long);
long    __stdcall PS35_SetJoyFEx (long,long,double);
double  __stdcall PS35_GetActFEx (long,long);
double  __stdcall PS35_GetVectorFEx (long,long);
long    __stdcall PS35_SetVectorFEx (long,long,double);
double  __stdcall PS35_GetAccelEx (long,long);
long    __stdcall PS35_SetAccelEx (long,long,double);
double  __stdcall PS35_GetDecelEx (long,long);
long    __stdcall PS35_SetDecelEx (long,long,double);
double  __stdcall PS35_GetBrakeDecelEx (long,long);
long    __stdcall PS35_SetBrakeDecelEx (long,long,double);
double  __stdcall PS35_GetRefDecelEx (long,long);
long    __stdcall PS35_SetRefDecelEx (long,long,double);
double  __stdcall PS35_GetJoyAccelEx (long,long);
long    __stdcall PS35_SetJoyAccelEx (long,long,double);
double  __stdcall PS35_GetVectorAccelEx (long,long);
long    __stdcall PS35_SetVectorAccelEx (long,long,double);
long	__stdcall PS35_GetOWISidData (long, long, long, char*, long);
long    __stdcall PS35_LoadTextFile (long, long, const char*);
long    __stdcall PS35_SaveTextFile (long, long, const char*);

// Communication
long    __stdcall PS35_LogFile (long, long, const char*, long, long);
long	__stdcall PS35_CmdAns (long, const char*, char*, long, long);
long	__stdcall PS35_CmdAnsEx (long, const char*, char*, long, long, long);
long    __stdcall PS35_GetReadError (long);

#ifdef __cplusplus
};
#endif

#endif	//__MYPS35
