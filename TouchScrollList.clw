
  MEMBER()

  INCLUDE('TouchScrollList.inc'),ONCE

    MAP
      MODULE('Windows')
        TSL:SetProp(ULONG,*CSTRING,ULONG),LONG, PROC, RAW, PASCAL, NAME('SetPropA')
        TSL:GetProp(ULONG,*CSTRING),ULONG, RAW, PASCAL, NAME('GetPropA')
        TSL:RemoveProp(ULONG,*CSTRING),ULONG, PROC, RAW, PASCAL, NAME('RemovePropA')
        TSL:CallWindowProc(UNSIGNED WNDProc,UNSIGNED hWnd,UNSIGNED uMsg,UNSIGNED wParam,LONG lParam),LONG,PASCAL,NAME('CallWindowProcA')
        TSL:DefWindowProc(UNSIGNED hWnd,UNSIGNED uMsg,UNSIGNED wParam,LONG lParam),LONG,PASCAL,NAME('DefWindowProcA')
        TSL:OutputDebugString(*CSTRING),PASCAL,RAW,NAME('OutputDebugStringA')
        TSL:ScreenToClient(UNSIGNED hWnd,LONG lpPoint),LONG,PROC,RAW,PASCAL,NAME('ScreenToClient')
        TSL:GetModuleHandle(*CSTRING lpModuleName),UNSIGNED,RAW,PASCAL,NAME('GetModuleHandleA')
        TSL:GetProcAddress(UNSIGNED hModule,*CSTRING lpProcName),LONG,RAW,PASCAL,NAME('GetProcAddress')
        !TSL:GetLastError(),LONG,PASCAL,NAME('GetLastError')
        !TSL:ScrollWindowEx(UNSIGNED hWnd,LONG dx,LONG dy,LONG prcScroll,LONG prcClip,LONG hrgnUpdate,LONG prcUpdate,UNSIGNED flags),LONG,PROC,RAW,PASCAL,NAME('ScrollWindowEx')
        !TSL:InvalidateRect(UNSIGNED hWnd,LONG lpRect,SIGNED bErase),LONG,PROC,RAW,PASCAL,NAME('InvalidateRect')
        !TSL:UpdateWindow(UNSIGNED hWnd),LONG,PROC,PASCAL,NAME('UpdateWindow')
      END
      MODULE('user32gesture') ! these must be checked and loaded at run time, not included before Windows 7 (user32 dll)
        TSL:CloseGestureInfoHandle(LONG hGestureInfo),LONG,RAW,PASCAL,DLL(1)
        TSL:GetGestureInfo(LONG hGestureInfo,LONG pGestureInfo),LONG,RAW,PASCAL,DLL(1)
        !TSL:GetGestureConfig
        !TSL:GetGestureExtraArgs
        !TSL:SetGestureConfig(LONG hWnd,LONG Reserved,LONG cIDs,LONG lpGestureConfig,LONG sizeGestureConfig),LONG,RAW,PASCAL,NAME('SetGestureConfig')
      END
      TouchListSubClassProc(UNSIGNED, UNSIGNED, UNSIGNED,LONG),LONG,PASCAL   ! Touch-Screen List SubClass Procedure
    END

TSL:GlobalInit       BYTE
TSL:GestureSupported BYTE
TSL:User32Module     LONG ! module handle
TSL:CloseGestureAddr LONG,NAME('TSL:CloseGestureInfoHandle') ! function pointer
TSL:GetGestureAddr   LONG,NAME('TSL:GetGestureInfo') ! function pointer
!mNumber              LONG

!------------------------------------------------------------------------------------------
TouchScrollList.Init  PROCEDURE(LONG TSL:Control) 
!------------------------------------------------------------------------------------------
userlib  CSTRING('user32.dll')
closestr CSTRING('CloseGestureInfoHandle')
getgistr CSTRING('GetGestureInfo')

  CODE
  IF ~TSL:GlobalInit ! check for OS support of gesture-related calls
    TSL:User32Module = TSL:GetModuleHandle(userlib)
    IF TSL:User32Module
      TSL:CloseGestureAddr = TSL:GetProcAddress(TSL:User32Module,closestr)
      TSL:GetGestureAddr = TSL:GetProcAddress(TSL:User32Module,getgistr)
      IF TSL:CloseGestureAddr AND TSL:GetGestureAddr
        TSL:GestureSupported = TRUE
      END
    END
    TSL:GlobalInit = TRUE
  END

  IF TSL:GestureSupported ! Win 7 and newer only
    ! Assign the major variables for the class 
    SELF.feq        = TSL:Control
    SELF.hWnd       = TSL:Control{Prop:Handle} 
    SELF.hWndProc   = TSL:Control{Prop:WndProc}   
    SELF.TSLThread  = THREAD()
    SELF.lineHeight = TSL:Control{PROP:LineHeight}

    ! Set variables as properties of the control for the Subclass Proc      
    TSL:SetProp(SELF.hWnd,TSL:LinkToFeq,TSL:Control)  
    TSL:SetProp(SELF.hWnd,TSL:LinkToClass,ADDRESS(SELF))
    TSL:SetProp(SELF.hWnd,TSL:LinkTohWndProc,SELF.hWndProc)
    TSL:SetProp(SELF.hWnd,TSL:LinkToThread,THREAD())

    ! Subclass the control
    TSL:Control{PROP:WNDProc} = ADDRESS(TouchListSubClassProc)! Subclass the control
  END

  RETURN

!------------------------------------------------------------------------------------------  
TouchScrollList.Kill  PROCEDURE()
!------------------------------------------------------------------------------------------
  CODE
  IF TSL:GestureSupported
    ! Remove the properties to prevent memory leaks
    TSL:RemoveProp(SELF.hWnd, TSL:LinkToClass)
    TSL:RemoveProp(SELF.hWnd, TSL:LinkTohWndProc)
    TSL:RemoveProp(SELF.hWnd, TSL:LinkToThread)
    TSL:RemoveProp(SELF.hWnd, TSL:LinkToFeq)
  END

  RETURN

!------------------------------------------------------------------------------------------     
TouchScrollList.Debug PROCEDURE(STRING argMsg)
!------------------------------------------------------------------------------------------
MyCstring   CSTRING(200)
  CODE
  IF SELF.debug
   MyCstring = '[TSL:]' & argMsg
   TSL:OutputDebugString(MyCstring)
  END

!==========================================================================================   
TouchListSubClassProc PROCEDURE(UNSIGNED MyHwnd,UNSIGNED usMsg, UNSIGNED wParam,LONG lParam)
!==========================================================================================
LinkTohWndProc    LONG
ReturnValue       LONG

! Subclass Procedure
MyTouchScrollList &TouchScrollList

result            SIGNED
ghandled          BOOL
scrollUnits       LONG
scrollLines       LONG

GI GROUP(GestureInfo)
   END

  CODE

   LinkTohWndProc = TSL:GetProp(MyHwnd, TSL:LinkTohWndProc)
   MyTouchScrollList &= TSL:GetProp(MyHwnd, TSL:LinkToClass)
   !MyTouchScrollList.debug(wparam & '-' & lparam & '-' & msg1)  !Uncomment this to detect codes

  CASE usMsg
  OF WM_GESTURE
    CLEAR(GI)
    GI.cbSize = SIZE(GI)
    result = TSL:GetGestureInfo(lParam, ADDRESS(GI))
    ghandled = FALSE

    IF result
      ! interpret the gesture
      CASE GI.dwID
      OF GID_PAN
        CASE GI.dwFlags
        OF GF_BEGIN
          MyTouchScrollList.startCoord.x = GI.ptsLocation.x
          MyTouchScrollList.startCoord.y = GI.ptsLocation.y
          TSL:ScreenToClient(MyHwnd,ADDRESS(MyTouchScrollList.startCoord))
        ELSE
          MyTouchScrollList.nextCoord.x = GI.ptsLocation.x
          MyTouchScrollList.nextCoord.y = GI.ptsLocation.y
          TSL:ScreenToClient(MyHwnd,ADDRESS(MyTouchScrollList.nextCoord))
          scrollLines = INT((MyTouchScrollList.nextCoord.y - MyTouchScrollList.startCoord.y) / MyTouchScrollList.lineHeight)
          scrollUnits = scrollLines * MyTouchScrollList.lineHeight
          MyTouchScrollList.feq{PROP:YOrigin} = MyTouchScrollList.feq{PROP:YOrigin} - scrollLines
          MyTouchScrollList.startCoord.y = MyTouchScrollList.startCoord.y + scrollUnits
          !TSL:ScrollWindowEx(MyHwnd,0,scrollUnits,0,0,0,0,0)
          !TSL:InvalidateRect(MyHwnd,0,TRUE)
          !TSL:UpdateWindow(MyHwnd)
        END
        ghandled = TRUE
      ! Add handling for any other gestures here
      END
    !ELSE ! GetGestureInfo failed
    !  DWORD dwErr = GetLastError()
    !  IF (dwErr > 0)
    !      !Message(hWnd, 'Error!', 'Could not retrieve a GESTUREINFO structure.', MB_OK)
    !  END
    !  mNumber += 1
    !  PUTINI('Errors',mNumber,'GetGestureInfo failed: '&TSL:GetLastError(),path()&'\tests.ini')
    END

    IF ghandled
      result = TSL:CloseGestureInfoHandle(lParam) ! close the handle to prevent memory leaks
      ReturnValue = 0
    ELSE
      ReturnValue = TSL:DefWindowProc(MyHwnd, usMsg, wParam, lParam) ! pass unhandled gesture messages on to default Windows procedure
    END
  ELSE
    ! Pass all other messages to the original window procedure
    ReturnValue = TSL:CallWindowProc(LinkTohWndProc, MyHwnd, usMsg, wParam, lParam)
  END

  RETURN ReturnValue

