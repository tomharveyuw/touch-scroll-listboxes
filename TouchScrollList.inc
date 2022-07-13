!ABCNotIncludeFile(TouchScrollList)
!File Name: TouchScrollList.inc


  OMIT('_EndOfInclude_',_TouchScrollListPresent_)
_TouchScrollListPresent_ EQUATE(1)

!Put any Global definitions here
TSL:LinkToClass         CSTRING('TSLClass')
TSL:LinkTohWndProc      CSTRING('TSLhWndProc')
TSL:LinkToThread        CSTRING('TSLThread')
TSL:LinkToFeq           CSTRING('TSLFeq')   

! Windows Message numbers (hex)
WM_GESTURE              EQUATE(0119h)

GWL_WndProc             EQUATE(-4)

! gesture identifier numbers returned with WM_GESTURE messages in the wParam value
GID_GLOBAL              EQUATE(0)
GID_BEGIN               EQUATE(1)
GID_END                 EQUATE(2)
GID_ZOOM                EQUATE(3)
GID_PAN                 EQUATE(4)
GID_ROTATE              EQUATE(5)
GID_TWOFINGERTAP        EQUATE(6)
GID_PRESSANDTAP         EQUATE(7)

! GestureConfig values for dwWant and dwBlock
GC_ALLGESTURES          EQUATE(0) ! only when using dwID = 0 (GID_GLOBAL)
GC_PAN                  EQUATE(1) ! only when using dwID = 4 (GID_PAN)

! gesture states as stored in GESTUREINFO dwFlags value
GF_BEGIN	            EQUATE(1) ! A gesture is starting
GF_INERTIA	            EQUATE(2) ! A gesture has triggered inertia
GF_END	                EQUATE(4) ! A gesture has finished

! Windows API data type equivalents
BOOL                    EQUATE(SIGNED)
DWORD                   EQUATE(ULONG)
HANDLE                  EQUATE(UNSIGNED)
UINT                    EQUATE(UNSIGNED)
LPCSTR                  EQUATE(CSTRING)    !Usage:Pass the Label of the LPCSTR
HINSTANCE               EQUATE(HANDLE)
HMENU                   EQUATE(HANDLE)
LPVOID                  EQUATE(ULONG)
HWND                    EQUATE(HANDLE)
WPARAM                  EQUATE(UINT)
LPARAM                  EQUATE(LONG)
LRESULT                 EQUATE(LONG)

! additional Windows API data types/groupings
ULONGLONG     GROUP,TYPE
LowPart         ULONG
HighPart        ULONG
              END

tagPOINTS     GROUP,TYPE
x               SHORT
y               SHORT
              END

tagPOINT      GROUP,TYPE
x               LONG
y               LONG
              END

GestureConfig GROUP,TYPE
dwID            LONG
dwWant          LONG
dwBlock         LONG
              END

GestureInfo   GROUP,TYPE
cbSize          UNSIGNED !UINT
dwFlags         ULONG !DWORD
dwID            ULONG !DWORD
hwndTarget      UNSIGNED !HWND
ptsLocation     GROUP ! LIKE(tagPOINTS)
x                 SHORT
y                 SHORT
                END
dwInstanceID    ULONG !DWORD
dwSequenceID    ULONG !DWORD
padding1        LONG  ! padding for 8-byte alignment
ullArguments    GROUP ! LIKE(ULONGLONG)
lowPart           ULONG
highPart          ULONG
                END
cbExtraArgs     UNSIGNED !UINT
padding2        LONG  ! padding for 8-byte alignment
              END

TouchScrollList CLASS,TYPE,MODULE('TouchScrollList.clw'), |
                          LINK('TouchScrollList.clw',_ABCLinkMode_),DLL(_ABCDLLMode_)

!=================================================
!Class Properties 
!=================================================
debug               BYTE(1)
feq                 LONG !Control FEQ
hWnd                LONG !Handle of Control
hWndProc            LONG !Handle of WndProc
TSLThread           LONG !Thread number
lineHeight          LONG !Height of each line in the listbox for making calculations
startCoord        GROUP  !Gesture message starting point
x                   LONG
y                   LONG
                  END
nextCoord         GROUP  !Gesture message updated point
x                   LONG
y                   LONG
                  END
 
!=================================================
! Class Procedure definitions
!=================================================
Init                 PROCEDURE(Long dControl)     
Kill                 PROCEDURE()                      
Debug                PROCEDURE(STRING ArgMsg)
                END

_EndOfInclude_
