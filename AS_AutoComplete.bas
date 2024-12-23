B4i=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.45
@EndOfDesignText@
Sub Class_Globals
	Type AS_AutoComplete_InputViewSource(Left As Int,Top As Int,Width As Int,Height As Int,RootLeft As Int,RootTop As Int)
	
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private xui As XUI 'ignore
	Public Tag As Object
	Private m_RootPanel As B4XView
	Private m_InputView As B4XView
	Private m_InputParent As B4XView
	
	Private xpnl_BackgroundPanel As B4XView
	
	Private g_InputViewSource As AS_AutoComplete_InputViewSource
	
	Private xiv_RefreshImage As B4XView
	
End Sub

'InputView - Can be any view, e.g. B4XFloatTextField or AS_TextFieldAdvanced
Public Sub Initialize (Callback As Object, EventName As String,RootPanel As B4XView,InputView As B4XView)
	mEventName = EventName
	mCallBack = Callback
	m_RootPanel = RootPanel
	m_InputView = InputView
	
	xpnl_BackgroundPanel = xui.CreatePanel("xpnl_BackgroundPanel")
	xpnl_BackgroundPanel.Visible = False
	RootPanel.AddView(xpnl_BackgroundPanel,RootPanel.Left,-RootPanel.Top,RootPanel.Width,RootPanel.Height + RootPanel.Top)
	xpnl_BackgroundPanel.Color = xui.Color_ARGB(0,0,0,0)
	
	m_InputParent = InputView.Parent
	
	xiv_RefreshImage = CreateImageView("")
	xiv_RefreshImage.Visible = False
	xpnl_BackgroundPanel.AddView(xiv_RefreshImage,RootPanel.Left,RootPanel.Top,RootPanel.Width,RootPanel.Height)
	
End Sub

#Region Methods

Public Sub Show
	If xpnl_BackgroundPanel.Visible = False Then
		
		g_InputViewSource.Initialize
		g_InputViewSource.Left = m_InputView.Left
		g_InputViewSource.Top = m_InputView.Top
		g_InputViewSource.Width = m_InputView.Width
		g_InputViewSource.Height = m_InputView.Height
		g_InputViewSource.RootLeft = ViewScreenPosition(m_InputView)(0)
		g_InputViewSource.RootTop = ViewScreenPosition(m_InputView)(1)
		
		xiv_RefreshImage.SetBitmap(m_RootPanel.Snapshot)
		xiv_RefreshImage.Visible = True
		xpnl_BackgroundPanel.SetVisibleAnimated(0,True)
		
		Sleep(0)
		
				#If B4A or B4I
		Dim ThisDummyTextField As B4XView = DummyTextField
		#End If
		
		m_InputView.RemoveViewFromParent
		xpnl_BackgroundPanel.AddView(m_InputView,g_InputViewSource.RootLeft,g_InputViewSource.RootTop,g_InputViewSource.Width,g_InputViewSource.Height)
		m_InputView.RequestFocus
				#If B4A or B4I
		ThisDummyTextField.RemoveViewFromParent
		#End If
		
'		Sleep(2000)
'		Log("jetzt")
		xiv_RefreshImage.Visible = False
		'xpnl_BackgroundPanel.SetVisibleAnimated(250,True)
		xpnl_BackgroundPanel.SetColorAnimated(250,xpnl_BackgroundPanel.Color,xui.Color_ARGB(152,0,0,0))
		
	End If
End Sub

'A dummy textfield to keep the keyboard open if the parent of the target textfield is changing
Private Sub DummyTextField As B4XView
	Dim tmpTextField As TextField
	tmpTextField.Initialize("")
	xpnl_BackgroundPanel.AddView(tmpTextField,0,0,0,0)
	tmpTextField.RequestFocus
	Return tmpTextField
End Sub

Public Sub Close
	xpnl_BackgroundPanel.SetVisibleAnimated(150,False)
	
	m_InputView.RemoveViewFromParent
	m_InputParent.AddView(m_InputView,g_InputViewSource.Left,g_InputViewSource.Top,g_InputViewSource.Width,g_InputViewSource.Height)
	Sleep(150)
	xpnl_BackgroundPanel.Color = xui.Color_Transparent
End Sub

'If the RootPanel resize
Public Sub Resize(Width As Float,Height As Float)
	xpnl_BackgroundPanel.SetLayoutAnimated(0,m_RootPanel.Left,-m_RootPanel.Top,m_RootPanel.Width,m_RootPanel.Height + m_RootPanel.Top)
	xiv_RefreshImage.SetLayoutAnimated(0,m_RootPanel.Left,m_RootPanel.Top,m_RootPanel.Width,m_RootPanel.Height)
End Sub

Public Sub TextChanged(Text As String)
	Show
End Sub

#End Region

#Region ViewEvents

#If B4J
Private Sub xpnl_BackgroundPanel_MouseClicked (EventData As MouseEvent)
#Else
Private Sub xpnl_BackgroundPanel_Click	
#End If
	Close
End Sub

#End Region

#Region Functions

Private Sub ViewScreenPosition (view As B4XView) As Int()
    
	Dim leftTop(2) As Int
    #IF B4A
    Dim JO As JavaObject = view
    JO.RunMethod("getLocationOnScreen", Array As Object(leftTop))
    leftTop(1) = leftTop(1) - view.Height
    #Else If B4I
	'https://www.b4x.com/android/forum/threads/absolute-position-of-view.56821/#content
    Dim parent As B4XView = view
    Do While GetType(parent) <> "B4IMainView"
        Dim no As NativeObject = parent
        leftTop(0) = leftTop(0) + parent.Left
        leftTop(1) = leftTop(1) + parent.Top
        parent = no.GetField("superview")
   Loop
    #Else
	Dim parent As B4XView = view
	Do While parent.IsInitialized
		leftTop(0) = leftTop(0) + parent.Left
		leftTop(1) = leftTop(1) + parent.Top
		parent = parent.Parent
	Loop
    #End If

	Return Array As Int(leftTop(0), leftTop(1))
End Sub

Private Sub CreateImageView(EventName As String) As B4XView
	Dim iv As ImageView
	iv.Initialize(EventName)
	Return iv
End Sub

#End Region