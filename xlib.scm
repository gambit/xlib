;;;============================================================================

;;; File: "xlib.scm"

;;; Copyright (c) 2005-2019 by Marc Feeley, All Rights Reserved.

;;;============================================================================

;;; A simple interface to the X Window System Xlib library.

;; Note: This interface to Xlib is still in development.  There are
;;       still memory leaks in the interface.

(##supply-module github.com/gambit/xlib)

(##meta-info pkg-config "x11")

;; help pkg-config find the x11.pc file on macOS and other platforms
(##meta-info pkg-config-path "/opt/X11/lib/pkgconfig")
(##meta-info pkg-config-path "/usr/local/X11/lib/pkgconfig")

(##namespace ("github.com/gambit/xlib#"))        ;; in github.com/gambit/xlib#
(##include "~~lib/_prim#.scm")                   ;; map fx+ to ##fx+, etc
(##include "~~lib/_gambit#.scm")                 ;; for macro-check-procedure,
                                                 ;; macro-absent-obj, etc

(##include "xlib#.scm")                          ;; correctly map names

(declare (extended-bindings)) ;; ##fx+ is bound to fixnum addition, etc
(declare (not safe))          ;; claim code has no type errors
(declare (block))             ;; claim no global is assigned (such as hamt?)

;;;============================================================================

(c-declare #<<end-of-c-declare

#include <X11/Xlib.h>
#include <X11/Xutil.h>

end-of-c-declare
)

;; Declare a few types so that the function prototypes use the same
;; type names as a C program.

(c-define-type Time unsigned-long)
(c-define-type XID unsigned-long)

(c-define-type Window XID)
(c-define-type Drawable XID)
(c-define-type Font XID)
(c-define-type Pixmap XID)
(c-define-type Cursor XID)
(c-define-type Colormap XID)
(c-define-type GContext XID)
(c-define-type KeySym XID)

(c-declare #<<end-of-c-declare

#define debug_free_not
#define really_free

#ifdef debug_free
#include <stdio.h>
#endif

___SCMOBJ release_rc_XGCValues(void *ptr) {

  XGCValues* p = ___CAST(XGCValues*, ptr);

#ifdef debug_free
  printf("release_rc_XGCValues(%p)\n", p);
  fflush(stdout);
#endif

#ifdef really_free
  ___EXT(___release_rc)(p);
#endif

  return ___FIX(___NO_ERR);
}

___SCMOBJ XFreeFontInfo_XFontStruct(void *ptr) {

  XFontStruct* p = ___CAST(XFontStruct*, ptr);

#ifdef debug_free
  printf("XFreeFontInfo_XFontStruct(%p)\n", p);
  fflush(stdout);
#endif

#ifdef really_free
  XFreeFontInfo(NULL, p, 1);
#endif

  return ___FIX(___NO_ERR);
}

___SCMOBJ release_rc_XColor(void *ptr) {

  XColor* p = ___CAST(XColor*, ptr);

#ifdef debug_free
  printf("release_rc_XColor(%p)\n", p);
  fflush(stdout);
#endif

#ifdef really_free
  ___EXT(___release_rc)( p );
#endif

  return ___FIX(___NO_ERR);
}

___SCMOBJ release_rc_XEvent(void *ptr) {

  XEvent* p = ptr;

#ifdef debug_free
  printf("release_rc_XEvent(%p)\n", p);
  fflush(stdout);
#endif

#ifdef really_free
  ___EXT(___release_rc)(p);
#endif

  return ___FIX(___NO_ERR);
}

end-of-c-declare
)

(c-define-type Bool int)
(c-define-type Status int)
(c-define-type GC (pointer (struct "_XGC") (GC)))
(c-define-type Visual "Visual")
(c-define-type Visual* (pointer Visual (Visual*)))
(c-define-type Display "Display")
(c-define-type Display* (pointer Display (Display*)))
(c-define-type Screen "Screen")
(c-define-type Screen* (pointer Screen (Screen*)))
(c-define-type XGCValues "XGCValues")
(c-define-type XGCValues* (pointer XGCValues (XGCValues*)))
(c-define-type XGCValues*/release-rc (pointer XGCValues (XGCValues*) "release_rc_XGCValues"))
(c-define-type XFontStruct "XFontStruct")
(c-define-type XFontStruct* (pointer XFontStruct (XFontStruct*)))
(c-define-type XFontStruct*/XFreeFontInfo (pointer XFontStruct (XFontStruct*) "XFreeFontInfo_XFontStruct"))
(c-define-type XColor "XColor")
(c-define-type XColor* (pointer XColor (XColor*)))
(c-define-type XColor*/release-rc (pointer XColor (XColor*) "release_rc_XColor"))
(c-define-type XEvent "XEvent")
(c-define-type XEvent* (pointer XEvent (XEvent*)))
(c-define-type XEvent*/release-rc (pointer XEvent (XEvent*) "release_rc_XEvent"))

(c-define-type char* char-string)

;; Function prototypes for a minimal subset of Xlib functions.  The
;; functions have the same name in Scheme and C.

(define XOpenDisplay
  (c-lambda (char*)        ;; display_name
            Display*
            "XOpenDisplay"))

(define XCloseDisplay
  (c-lambda (Display*)     ;; display
            int
            "XCloseDisplay"))

(define XDefaultScreen
  (c-lambda (Display*)     ;; display
            int
            "XDefaultScreen"))

(define XScreenOfDisplay
  (c-lambda (Display*      ;; display
             int)          ;; screen_number
            Screen*
            "XScreenOfDisplay"))

(define XDefaultColormapOfScreen
  (c-lambda (Screen*)      ;; screen
            Colormap
            "XDefaultColormapOfScreen"))

(define XClearWindow
  (c-lambda (Display*      ;; display
             Window)       ;; w
            int
            "XClearWindow"))

(define XConnectionNumber
  (c-lambda (Display*)     ;; display
            int
            "XConnectionNumber"))

(define XRootWindow
  (c-lambda (Display*      ;; display
             int)          ;; screen_number
            Window
            "XRootWindow"))

(define XDefaultRootWindow
  (c-lambda (Display*)     ;; display
            Window
            "XDefaultRootWindow"))

(define XRootWindowOfScreen
  (c-lambda (Screen*)      ;; screen
            Window
            "XRootWindowOfScreen"))

(define XDefaultVisual
  (c-lambda (Display*      ;; display
             int)          ;; screen_number
            Visual*
            "XDefaultVisual"))

(define XDefaultVisualOfScreen
  (c-lambda (Screen*)      ;; screen
            Visual*
            "XDefaultVisualOfScreen"))

(define XDefaultGC
  (c-lambda (Display*      ;; display
             int)          ;; screen_number
            GC
            "XDefaultGC"))

(define XDefaultGCOfScreen
  (c-lambda (Screen*)      ;; screen
            GC
            "XDefaultGCOfScreen"))

(define XBlackPixel
  (c-lambda (Display*       ;; display
             int)           ;; screen_number
            unsigned-long
            "XBlackPixel"))

(define XWhitePixel
  (c-lambda (Display*       ;; display
             int)           ;; screen_number
            unsigned-long
            "XWhitePixel"))

(define XCreateSimpleWindow
  (c-lambda (Display*       ;; display
             Window         ;; parent
             int            ;; x
             int            ;; y
             unsigned-int   ;; width
             unsigned-int   ;; height
             unsigned-int   ;; border_width
             unsigned-long  ;; border
             unsigned-long) ;; backgound
            Window
            "XCreateSimpleWindow"))

(define XMapWindow
  (c-lambda (Display*       ;; display
             Window)        ;; w
            int
            "XMapWindow"))

(define XResizeWindow
  (c-lambda (Display*       ;; display
             Window         ;; w
             unsigned-int   ;; width
             unsigned-int)  ;; height
            int
            "XResizeWindow"))

(define XFlush
  (c-lambda (Display*)      ;; display
            int
            "XFlush"))

(define XCreateGC
  (c-lambda (Display*       ;; display
             Drawable       ;; d
             unsigned-long  ;; valuemask
             XGCValues*)    ;; values
            GC
            "XCreateGC"))

(define XFreeGC
  (c-lambda (Display*       ;; display
             GC)            ;; gc
            int
            "XFreeGC"))

(define XFillRectangle
  (c-lambda (Display*      ;; display
             Drawable      ;; d
             GC            ;; gc
             int           ;; x
             int           ;; y
             unsigned-int  ;; width
             unsigned-int) ;; height
            int
            "XFillRectangle"))

(define XFillArc
  (c-lambda (Display*      ;; display
             Drawable      ;; d
             GC            ;; gc
             int           ;; x
             int           ;; y
             unsigned-int  ;; width
             unsigned-int  ;; height
             int           ;; angle1
             int)          ;; angle2
            int
            "XFillArc"))

(define XDrawString
  (c-lambda (Display*      ;; display
             Drawable      ;; d
             GC            ;; gc
             int           ;; x
             int           ;; y
             char*         ;; string
             int)          ;; length
            int
            "XDrawString"))

(define XTextWidth
  (c-lambda (XFontStruct*  ;; font_struct
             char*         ;; string
             int)          ;; count
            int
            "XTextWidth"))

(define XParseColor
  (c-lambda (Display*      ;; display
             Colormap      ;; colormap
             char*         ;; spec
             XColor*)      ;; exact_def_return
            Status
            "XParseColor"))

(define XAllocColor
  (c-lambda (Display*      ;; display
             Colormap      ;; colormap
             XColor*)      ;; screen_in_out
            Status
            "XAllocColor"))

(define (make-XColor-box)
  ((c-lambda ()
             XColor*/release-rc
             "___return(___EXT(___alloc_rc)(sizeof (XColor)));")))

(define XColor-pixel
  (c-lambda (XColor*)       ;; XColor box
             unsigned-long
            "___return(___arg1->pixel);"))

(define XColor-pixel-set!
  (c-lambda (XColor*        ;; XColor box
             unsigned-long) ;; intensity
            void
            "___arg1->pixel = ___arg2;"))

(define XColor-red
  (c-lambda (XColor*)       ;; XColor box
             unsigned-short
            "___return(___arg1->red);"))

(define XColor-red-set!
  (c-lambda (XColor*        ;; XColor box
             unsigned-short);; intensity
            void
            "___arg1->red = ___arg2;"))

(define XColor-green
  (c-lambda (XColor*)       ;; XColor box
             unsigned-short
            "___return(___arg1->green);"))

(define XColor-green-set!
  (c-lambda (XColor*        ;; XColor box
             unsigned-short);; intensity
            void
            "___arg1->green = ___arg2;"))

(define XColor-blue
  (c-lambda (XColor*)       ;; XColor box
             unsigned-short
            "___return(___arg1->blue);"))

(define XColor-blue-set!
  (c-lambda (XColor*        ;; XColor box
             unsigned-short);; intensity
            void
            "___arg1->blue = ___arg2;"))

(define (make-XGCValues-box)
  ((c-lambda ()
             XGCValues*/release-rc
             "___return(___EXT(___alloc_rc)(sizeof (XGCValues)));")))

(define XGCValues-foreground
  (c-lambda (XGCValues*)    ;; XGCValues box
            unsigned-long
            "___return(___arg1->foreground);"))

(define XGCValues-foreground-set!
  (c-lambda (XGCValues*     ;; XGCValues box
             unsigned-long) ;; pixel index
            void
            "___arg1->foreground = ___arg2;"))

(define XGCValues-background
  (c-lambda (XGCValues*)    ;; XGCValues box
            unsigned-long
            "___return(___arg1->background);"))

(define XGCValues-background-set!
  (c-lambda (XGCValues*     ;; XGCValues box
             unsigned-long) ;; pixel index
            void
            "___arg1->background = ___arg2;"))

(define XGCValues-font
  (c-lambda (XGCValues*)    ;; XGCValues box
            Font
            "___return(___arg1->font);"))

(define XGCValues-font-set!
  (c-lambda (XGCValues*     ;; XGCValues box
             Font)          ;; font_ID
            void
            "___arg1->font = ___arg2;"))

(define GCFunction
  ((c-lambda () unsigned-long "___return(GCFunction);")))

(define GCPlaneMask
  ((c-lambda () unsigned-long "___return(GCPlaneMask);")))

(define GCForeground
  ((c-lambda () unsigned-long "___return(GCForeground);")))

(define GCBackground
  ((c-lambda () unsigned-long "___return(GCBackground);")))

(define GCLineWidth
  ((c-lambda () unsigned-long "___return(GCLineWidth);")))

(define GCLineStyle
  ((c-lambda () unsigned-long "___return(GCLineStyle);")))

(define GCCapStyle
  ((c-lambda () unsigned-long "___return(GCCapStyle);")))

(define GCJoinStyle
  ((c-lambda () unsigned-long "___return(GCJoinStyle);")))

(define GCFillStyle
  ((c-lambda () unsigned-long "___return(GCFillStyle);")))

(define GCFillRule
  ((c-lambda () unsigned-long "___return(GCFillRule);")))

(define GCTile
  ((c-lambda () unsigned-long "___return(GCTile);")))

(define GCStipple
  ((c-lambda () unsigned-long "___return(GCStipple);")))

(define GCTileStipXOrigin
  ((c-lambda () unsigned-long "___return(GCTileStipXOrigin);")))

(define GCTileStipYOrigin
  ((c-lambda () unsigned-long "___return(GCTileStipYOrigin);")))

(define GCFont
  ((c-lambda () unsigned-long "___return(GCFont);")))

(define GCSubwindowMode
  ((c-lambda () unsigned-long "___return(GCSubwindowMode);")))

(define GCGraphicsExposures
  ((c-lambda () unsigned-long "___return(GCGraphicsExposures);")))

(define GCClipXOrigin
  ((c-lambda () unsigned-long "___return(GCClipXOrigin);")))

(define GCClipYOrigin
  ((c-lambda () unsigned-long "___return(GCClipYOrigin);")))

(define GCClipMask
  ((c-lambda () unsigned-long "___return(GCClipMask);")))

(define GCDashOffset
  ((c-lambda () unsigned-long "___return(GCDashOffset);")))

(define GCDashList
  ((c-lambda () unsigned-long "___return(GCDashList);")))

(define GCArcMode
  ((c-lambda () unsigned-long "___return(GCArcMode);")))

(define XChangeGC
  (c-lambda (Display*       ;; display
             GC             ;; gc
             unsigned-long  ;; valuemask
             XGCValues*)    ;; values
            int
            "XChangeGC"))

(define XGetGCValues
  (c-lambda (Display*       ;; display
             GC             ;; gc
             unsigned-long  ;; valuemask
             XGCValues*)    ;; values_return
            int
            "XGetGCValues"))

(define XQueryFont
  (c-lambda (Display*       ;; display
             Font)          ;; font_ID
            XFontStruct*/XFreeFontInfo
            "XQueryFont"))

(define XFreeFontInfo
  (c-lambda (nonnull-char-string-list ;; names
             XFontStruct*             ;; free_info
             int)                     ;; actual_count
            int
            "XFreeFontInfo"))

(define XLoadFont
  (c-lambda (Display*       ;; display
             char*)         ;; name
            Font
            "XLoadFont"))

(define XUnloadFont
  (c-lambda (Display*       ;; display
             Font)          ;; font
            int
            "XUnloadFont"))

(define XLoadQueryFont
  (c-lambda (Display*       ;; display
             char*)         ;; name
            XFontStruct*/XFreeFontInfo
            "XLoadQueryFont"))

(define XFreeFont
  (c-lambda (Display*       ;; display
             XFontStruct*)  ;; font_struct
            int
            "XFreeFont"))

(define XFontStruct-fid
  (c-lambda (XFontStruct*)  ;; font_struct
            Font
            "___return(___arg1->fid);"))

(define XFontStruct-ascent
  (c-lambda (XFontStruct*)  ;; font_struct
            int
            "___return(___arg1->ascent);"))

(define XFontStruct-descent
  (c-lambda (XFontStruct*)  ;; font_struct
            int
            "___return(___arg1->descent);"))

(define NoEventMask
  ((c-lambda () long "___return(NoEventMask);")))

(define KeyPressMask
  ((c-lambda () long "___return(KeyPressMask);")))

(define KeyReleaseMask
  ((c-lambda () long "___return(KeyReleaseMask);")))

(define ButtonPressMask
  ((c-lambda () long "___return(ButtonPressMask);")))

(define ButtonReleaseMask
  ((c-lambda () long "___return(ButtonReleaseMask);")))

(define EnterWindowMask
  ((c-lambda () long "___return(EnterWindowMask);")))

(define LeaveWindowMask
  ((c-lambda () long "___return(LeaveWindowMask);")))

(define PointerMotionMask
  ((c-lambda () long "___return(PointerMotionMask);")))

(define PointerMotionHintMask
  ((c-lambda () long "___return(PointerMotionHintMask);")))

(define Button1MotionMask
  ((c-lambda () long "___return(Button1MotionMask);")))

(define Button2MotionMask
  ((c-lambda () long "___return(Button2MotionMask);")))

(define Button3MotionMask
  ((c-lambda () long "___return(Button3MotionMask);")))

(define Button4MotionMask
  ((c-lambda () long "___return(Button4MotionMask);")))

(define Button5MotionMask
  ((c-lambda () long "___return(Button5MotionMask);")))

(define ButtonMotionMask
  ((c-lambda () long "___return(ButtonMotionMask);")))

(define KeymapStateMask
  ((c-lambda () long "___return(KeymapStateMask);")))

(define ExposureMask
  ((c-lambda () long "___return(ExposureMask);")))

(define VisibilityChangeMask
  ((c-lambda () long "___return(VisibilityChangeMask);")))

(define StructureNotifyMask
  ((c-lambda () long "___return(StructureNotifyMask);")))

(define ResizeRedirectMask
  ((c-lambda () long "___return(ResizeRedirectMask);")))

(define SubstructureNotifyMask
  ((c-lambda () long "___return(SubstructureNotifyMask);")))

(define SubstructureRedirectMask
  ((c-lambda () long "___return(SubstructureRedirectMask);")))

(define FocusChangeMask
  ((c-lambda () long "___return(FocusChangeMask);")))

(define PropertyChangeMask
  ((c-lambda () long "___return(PropertyChangeMask);")))

(define ColormapChangeMask
  ((c-lambda () long "___return(ColormapChangeMask);")))

(define OwnerGrabButtonMask
  ((c-lambda () long "___return(OwnerGrabButtonMask);")))

(define KeyPress
  ((c-lambda () long "___return(KeyPress);")))

(define KeyRelease
  ((c-lambda () long "___return(KeyRelease);")))

(define ButtonPress
  ((c-lambda () long "___return(ButtonPress);")))

(define ButtonRelease
  ((c-lambda () long "___return(ButtonRelease);")))

(define MotionNotify
  ((c-lambda () long "___return(MotionNotify);")))

(define EnterNotify
  ((c-lambda () long "___return(EnterNotify);")))

(define LeaveNotify
  ((c-lambda () long "___return(LeaveNotify);")))

(define FocusIn
  ((c-lambda () long "___return(FocusIn);")))

(define FocusOut
  ((c-lambda () long "___return(FocusOut);")))

(define KeymapNotify
  ((c-lambda () long "___return(KeymapNotify);")))

(define Expose
  ((c-lambda () long "___return(Expose);")))

(define GraphicsExpose
  ((c-lambda () long "___return(GraphicsExpose);")))

(define NoExpose
  ((c-lambda () long "___return(NoExpose);")))

(define VisibilityNotify
  ((c-lambda () long "___return(VisibilityNotify);")))

(define CreateNotify
  ((c-lambda () long "___return(CreateNotify);")))

(define DestroyNotify
  ((c-lambda () long "___return(DestroyNotify);")))

(define UnmapNotify
  ((c-lambda () long "___return(UnmapNotify);")))

(define MapNotify
  ((c-lambda () long "___return(MapNotify);")))

(define MapRequest
  ((c-lambda () long "___return(MapRequest);")))

(define ReparentNotify
  ((c-lambda () long "___return(ReparentNotify);")))

(define ConfigureNotify
  ((c-lambda () long "___return(ConfigureNotify);")))

(define ConfigureRequest
  ((c-lambda () long "___return(ConfigureRequest);")))

(define GravityNotify
  ((c-lambda () long "___return(GravityNotify);")))

(define ResizeRequest
  ((c-lambda () long "___return(ResizeRequest);")))

(define CirculateNotify
  ((c-lambda () long "___return(CirculateNotify);")))

(define CirculateRequest
  ((c-lambda () long "___return(CirculateRequest);")))

(define PropertyNotify
  ((c-lambda () long "___return(PropertyNotify);")))

(define SelectionClear
  ((c-lambda () long "___return(SelectionClear);")))

(define SelectionRequest
  ((c-lambda () long "___return(SelectionRequest);")))

(define SelectionNotify
  ((c-lambda () long "___return(SelectionNotify);")))

(define ColormapNotify
  ((c-lambda () long "___return(ColormapNotify);")))

(define ClientMessage
  ((c-lambda () long "___return(ClientMessage);")))

(define MappingNotify
  ((c-lambda () long "___return(MappingNotify);")))

(define XCheckMaskEvent
  (c-lambda (Display*       ;; display
             long)          ;; event_mask
            XEvent*/release-rc
#<<end-of-c-lambda
XEvent ev;
XEvent* pev;
if (XCheckMaskEvent(___arg1, ___arg2, &ev)) {
  pev = ___CAST(XEvent*, ___EXT(___alloc_rc)(sizeof(ev)));
  *pev = ev;
} else {
  pev = NULL;
}
___return(pev);
end-of-c-lambda
))

(define XSelectInput
  (c-lambda (Display*       ;; display
             Window         ;; w
             long)          ;; event_mask
            int
            "XSelectInput"))

(define XAnyEvent-type
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->type);"))

(define XAnyEvent-serial
  (c-lambda (XEvent*)       ;; XEvent box
            unsigned-long
            "___return(___arg1->xany.serial);"))

(define XAnyEvent-send-event
  (c-lambda (XEvent*)       ;; XEvent box
            bool
            "___return(___arg1->xany.send_event);"))

(define XAnyEvent-display
  (c-lambda (XEvent*)       ;; XEvent box
            Display*
            "___return(___arg1->xany.display);"))

(define XAnyEvent-window
  (c-lambda (XEvent*)       ;; XEvent box
            Window
            "___return(___arg1->xany.window);"))

(define XKeyEvent-root
  (c-lambda (XEvent*)       ;; XEvent box
            Window
            "___return(___arg1->xkey.root);"))

(define XKeyEvent-subwindow
  (c-lambda (XEvent*)       ;; XEvent box
            Window
            "___return(___arg1->xkey.subwindow);"))

(define XKeyEvent-time
  (c-lambda (XEvent*)       ;; XEvent box
            Time
            "___return(___arg1->xkey.time);"))

(define XKeyEvent-x
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xkey.x);"))

(define XKeyEvent-y
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xkey.y);"))

(define XKeyEvent-x-root
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xkey.x_root);"))

(define XKeyEvent-y-root
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xkey.y_root);"))

(define XKeyEvent-state
  (c-lambda (XEvent*)       ;; XEvent box
            unsigned-int
            "___return(___arg1->xkey.state);"))

(define XKeyEvent-keycode
  (c-lambda (XEvent*)       ;; XEvent box
            unsigned-int
            "___return(___arg1->xkey.keycode);"))

(define XKeyEvent-same-screen
  (c-lambda (XEvent*)       ;; XEvent box
            bool
            "___return(___arg1->xkey.same_screen);"))

(define XButtonEvent-root
  (c-lambda (XEvent*)       ;; XEvent box
            Window
            "___return(___arg1->xbutton.root);"))

(define XButtonEvent-subwindow
  (c-lambda (XEvent*)       ;; XEvent box
            Window
            "___return(___arg1->xbutton.subwindow);"))

(define XButtonEvent-time
  (c-lambda (XEvent*)       ;; XEvent box
            Time
            "___return(___arg1->xbutton.time);"))

(define XButtonEvent-x
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xbutton.x);"))

(define XButtonEvent-y
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xbutton.y);"))

(define XButtonEvent-x-root
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xbutton.x_root);"))

(define XButtonEvent-y-root
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xbutton.y_root);"))

(define XButtonEvent-state
  (c-lambda (XEvent*)       ;; XEvent box
            unsigned-int
            "___return(___arg1->xbutton.state);"))

(define XButtonEvent-button
  (c-lambda (XEvent*)       ;; XEvent box
            unsigned-int
            "___return(___arg1->xbutton.button);"))

(define XButtonEvent-same-screen
  (c-lambda (XEvent*)       ;; XEvent box
            bool
            "___return(___arg1->xbutton.same_screen);"))

(define XMotionEvent-root
  (c-lambda (XEvent*)       ;; XEvent box
            Window
            "___return(___arg1->xmotion.root);"))

(define XMotionEvent-subwindow
  (c-lambda (XEvent*)       ;; XEvent box
            Window
            "___return(___arg1->xmotion.subwindow);"))

(define XMotionEvent-time
  (c-lambda (XEvent*)       ;; XEvent box
            Time
            "___return(___arg1->xmotion.time);"))

(define XMotionEvent-x
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xmotion.x);"))

(define XMotionEvent-y
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xmotion.y);"))

(define XMotionEvent-x-root
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xmotion.x_root);"))

(define XMotionEvent-y-root
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xmotion.y_root);"))

(define XMotionEvent-state
  (c-lambda (XEvent*)       ;; XEvent box
            unsigned-int
            "___return(___arg1->xmotion.state);"))

(define XMotionEvent-is-hint
  (c-lambda (XEvent*)       ;; XEvent box
            char
            "___return(___arg1->xmotion.is_hint);"))

(define XMotionEvent-same-screen
  (c-lambda (XEvent*)       ;; XEvent box
            bool
            "___return(___arg1->xmotion.same_screen);"))

(define XCrossingEvent-root
  (c-lambda (XEvent*)       ;; XEvent box
            Window
            "___return(___arg1->xcrossing.root);"))

(define XCrossingEvent-subwindow
  (c-lambda (XEvent*)       ;; XEvent box
            Window
            "___return(___arg1->xcrossing.subwindow);"))

(define XCrossingEvent-time
  (c-lambda (XEvent*)       ;; XEvent box
            Time
            "___return(___arg1->xcrossing.time);"))

(define XCrossingEvent-x
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xcrossing.x);"))

(define XCrossingEvent-y
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xcrossing.y);"))

(define XCrossingEvent-x-root
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xcrossing.x_root);"))

(define XCrossingEvent-y-root
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xcrossing.y_root);"))

(define XCrossingEvent-mode
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xcrossing.mode);"))

(define XCrossingEvent-detail
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xcrossing.detail);"))

(define XCrossingEvent-same-screen
  (c-lambda (XEvent*)       ;; XEvent box
            bool
            "___return(___arg1->xcrossing.same_screen);"))

(define XCrossingEvent-focus
  (c-lambda (XEvent*)       ;; XEvent box
            bool
            "___return(___arg1->xcrossing.focus);"))

(define XCrossingEvent-state
  (c-lambda (XEvent*)       ;; XEvent box
            unsigned-int
            "___return(___arg1->xcrossing.state);"))

(define XConfigureEvent-x
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xconfigure.x);"))

(define XConfigureEvent-y
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xconfigure.y);"))

(define XConfigureEvent-width
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xconfigure.width);"))

(define XConfigureEvent-height
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xconfigure.height);"))

(define XConfigureEvent-border-width
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xconfigure.border_width);"))

(define XResizeRequestEvent-width
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xresizerequest.width);"))

(define XResizeRequestEvent-height
  (c-lambda (XEvent*)       ;; XEvent box
            int
            "___return(___arg1->xresizerequest.height);"))

(define XLookupString
  (c-lambda (XEvent*)      ;; event_struct (XKeyEvent)
            KeySym
#<<end-of-c-lambda
char buf[10];
KeySym ks;
XComposeStatus cs;
int n = XLookupString(___CAST(XKeyEvent*, ___arg1),
                      buf,
                      sizeof (buf),
                      &ks,
                      &cs);
___return(ks);
end-of-c-lambda
))

(define (convert-XEvent ev)
  (and ev
       (let ((type (XAnyEvent-type ev)))

         (cond ((or (fx= type KeyPress)
                    (fx= type KeyRelease))
                (vector
                 (if (fx= type KeyPress)
                     'XKeyPressedEvent
                     'XKeyReleasedEvent)
                 type
                 (XAnyEvent-serial ev)
                 (XAnyEvent-send-event ev)
                 (XAnyEvent-display ev)
                 (XAnyEvent-window ev)
                 (XKeyEvent-root ev)
                 (XKeyEvent-subwindow ev)
                 (XKeyEvent-time ev)
                 (XKeyEvent-x ev)
                 (XKeyEvent-y ev)
                 (XKeyEvent-x-root ev)
                 (XKeyEvent-y-root ev)
                 (XKeyEvent-state ev)
                 (XKeyEvent-keycode ev)
                 (XKeyEvent-same-screen ev)
                 (XLookupString ev)))

               ((or (fx= type ButtonPress)
                    (fx= type ButtonRelease))
                (vector
                 (if (fx= type ButtonPress)
                     'XButtonPressedEvent
                     'XButtonReleasedEvent)
                 type
                 (XAnyEvent-serial ev)
                 (XAnyEvent-send-event ev)
                 (XAnyEvent-display ev)
                 (XAnyEvent-window ev)
                 (XButtonEvent-root ev)
                 (XButtonEvent-subwindow ev)
                 (XButtonEvent-time ev)
                 (XButtonEvent-x ev)
                 (XButtonEvent-y ev)
                 (XButtonEvent-x-root ev)
                 (XButtonEvent-y-root ev)
                 (XButtonEvent-state ev)
                 (XButtonEvent-button ev)
                 (XButtonEvent-same-screen ev)))

               ((fx= type MotionNotify)
                (vector
                 'XPointerMovedEvent
                 type
                 (XAnyEvent-serial ev)
                 (XAnyEvent-send-event ev)
                 (XAnyEvent-display ev)
                 (XAnyEvent-window ev)
                 (XMotionEvent-root ev)
                 (XMotionEvent-subwindow ev)
                 (XMotionEvent-time ev)
                 (XMotionEvent-x ev)
                 (XMotionEvent-y ev)
                 (XMotionEvent-x-root ev)
                 (XMotionEvent-y-root ev)
                 (XMotionEvent-state ev)
                 (XMotionEvent-is-hint ev)
                 (XMotionEvent-same-screen ev)))

               ((or (fx= type EnterNotify)
                    (fx= type LeaveNotify))
                (vector
                 (if (fx= type EnterNotify)
                     'XEnterWindowEvent
                     'XLeaveWindowEvent)
                 type
                 (XAnyEvent-serial ev)
                 (XAnyEvent-send-event ev)
                 (XAnyEvent-display ev)
                 (XAnyEvent-window ev)
                 (XCrossingEvent-root ev)
                 (XCrossingEvent-subwindow ev)
                 (XCrossingEvent-time ev)
                 (XCrossingEvent-x ev)
                 (XCrossingEvent-y ev)
                 (XCrossingEvent-x-root ev)
                 (XCrossingEvent-y-root ev)
                 (XCrossingEvent-mode ev)
                 (XCrossingEvent-detail ev)
                 (XCrossingEvent-same-screen ev)
                 (XCrossingEvent-focus ev)
                 (XCrossingEvent-state ev)))

               ((fx= type ConfigureNotify)
                (vector
                 'XConfigureEvent
                 type
                 (XAnyEvent-serial ev)
                 (XAnyEvent-send-event ev)
                 (XAnyEvent-display ev)
                 (XAnyEvent-window ev)
                 (XConfigureEvent-x ev)
                 (XConfigureEvent-y ev)
                 (XConfigureEvent-width ev)
                 (XConfigureEvent-height ev)
                 (XConfigureEvent-border-width ev)))

               ((fx= type ResizeRequest)
                (vector
                 'XResizeRequestEvent
                 type
                 (XAnyEvent-serial ev)
                 (XAnyEvent-send-event ev)
                 (XAnyEvent-display ev)
                 (XAnyEvent-window ev)
                 (XResizeRequestEvent-width ev)
                 (XResizeRequestEvent-height ev)))

               (else
                #f)))))

;;;============================================================================
