B4i=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.45
@EndOfDesignText@
#If Documentation
Updates
V1.00
	-Release
#End If
	
#Event: ItemClicked(Item As AS_SelectionList_Item)

Sub Class_Globals
	Type AS_AutoComplete_InputViewSource(Left As Int,Top As Int,Width As Int,Height As Int,RootLeft As Int,RootTop As Int)
	Type AS_AutoComplete_DataSource1(Database As SQL,Query As String,SearchColumns() As String,DisplayTextColumn As String,ValueColumn As String)
	
	Private g_DataSource1 As AS_AutoComplete_DataSource1
	
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
	
	Private AS_SelectionList1 As AS_SelectionList
	Private m_SuggestionMatchCount As Int = 2
	Private m_MaxVisibleItems As Int = 5
	Private isOpen As Boolean = False
	Private m_AfterItemClickCoolDown As Long = 1000
	Private m_AutoCloseOnItemClick As Boolean = True
	Private m_IgnoreTextChange As Boolean = False
	Private m_TextField2ListGap As Float = 5dip
	
End Sub

Public Sub setTheme(Theme As AS_SelectionList_Theme)
	AS_SelectionList1.Theme = Theme
End Sub

Public Sub getTheme_Dark As AS_SelectionList_Theme
	Return AS_SelectionList1.Theme_Dark
End Sub

Public Sub getTheme_Light As AS_SelectionList_Theme
	Return AS_SelectionList1.Theme_Light
End Sub

'InputView - Can be any view, e.g. B4XFloatTextField or AS_TextFieldAdvanced
Public Sub Initialize (Callback As Object, EventName As String,RootPanel As B4XView,InputView As B4XView)
	mEventName = EventName
	mCallBack = Callback
	m_RootPanel = RootPanel
	m_InputView = InputView
	
	xpnl_BackgroundPanel = xui.CreatePanel("xpnl_BackgroundPanel")
	xpnl_BackgroundPanel.Visible = False
	RootPanel.AddView(xpnl_BackgroundPanel,m_RootPanel.Left,-m_RootPanel.Top,m_RootPanel.Width,m_RootPanel.Height + m_RootPanel.Top)
	xpnl_BackgroundPanel.Color = xui.Color_ARGB(0,0,0,0)
	
	m_InputParent = InputView.Parent
	
	xiv_RefreshImage = CreateImageView("")
	xiv_RefreshImage.Visible = False
	xpnl_BackgroundPanel.AddView(xiv_RefreshImage,m_RootPanel.Left,m_RootPanel.Top,m_RootPanel.Width,m_RootPanel.Height)
	
	AS_SelectionList1.Initialize(Me,"AS_SelectionList1")
	AS_SelectionList1.CreateViewPerCode(xpnl_BackgroundPanel,0,0,xpnl_BackgroundPanel.Width,100dip)
	AS_SelectionList1.SelectionMode = AS_SelectionList1.SelectionMode_Single
	AS_SelectionList1.CornerRadius = 0
	AS_SelectionList1.SideGap = 0
	
End Sub

#Region Methods

Public Sub Show
	If xpnl_BackgroundPanel.Visible = False Then
		isOpen = True
		g_InputViewSource.Initialize
		g_InputViewSource.Left = m_InputView.Left
		g_InputViewSource.Top = m_InputView.Top
		g_InputViewSource.Width = m_InputView.Width
		g_InputViewSource.Height = m_InputView.Height
		g_InputViewSource.RootLeft = ViewScreenPosition(m_InputView)(0)
		g_InputViewSource.RootTop = ViewScreenPosition(m_InputView)(1)
		
		#If B4I
		xiv_RefreshImage.SetBitmap(m_RootPanel.Snapshot)
		xiv_RefreshImage.Visible = True
		#End if
		xpnl_BackgroundPanel.SetVisibleAnimated(0,True)
		
		Sleep(0)
		
		#If B4I
		Dim ThisDummyTextField As B4XView = DummyTextField
		#End If
		
		m_InputView.RemoveViewFromParent
		xpnl_BackgroundPanel.AddView(m_InputView,g_InputViewSource.RootLeft,g_InputViewSource.RootTop,g_InputViewSource.Width,g_InputViewSource.Height)
		m_InputView.RequestFocus
		#If B4I
		ThisDummyTextField.RemoveViewFromParent
		#End If
		
		AS_SelectionList1.Base_Resize(g_InputViewSource.Width,AS_SelectionList1.ItemProperties.Height*m_MaxVisibleItems)
		AS_SelectionList1.mBase.left = g_InputViewSource.RootLeft
		AS_SelectionList1.mBase.Top = g_InputViewSource.RootTop + g_InputViewSource.Height + m_TextField2ListGap
		
		'Sleep(2000)
		'Log("jetzt")
		xiv_RefreshImage.Visible = False
		xpnl_BackgroundPanel.SetVisibleAnimated(250,True)
		xpnl_BackgroundPanel.SetColorAnimated(250,xpnl_BackgroundPanel.Color,xui.Color_ARGB(152,0,0,0))
		
	End If
End Sub

#If B4I
'A dummy textfield to keep the keyboard open if the parent of the target textfield is changing
Private Sub DummyTextField As B4XView
	Dim tmpTextField As TextField
	tmpTextField.Initialize("")
	xpnl_BackgroundPanel.AddView(tmpTextField,0,0,0,0)
	tmpTextField.RequestFocus
	Return tmpTextField
End Sub
	#End If

Public Sub Close
	isOpen = False
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
	
	g_InputViewSource.Width = m_InputView.Width
	g_InputViewSource.Height = m_InputView.Height
	
	AS_SelectionList1.Base_Resize(g_InputViewSource.Width,AS_SelectionList1.ItemProperties.Height*m_MaxVisibleItems)
End Sub

Public Sub TextChanged(Text As String)
	If m_IgnoreTextChange Then Return
	If Text.Length >= m_SuggestionMatchCount Then
		Show
		FetchNewData(Text)
	Else if isOpen Then
		Close
	End If
End Sub

Private Sub FetchNewData(SearchText As String)
	If g_DataSource1.IsInitialized Then
        
		Dim lstParameters As List
		lstParameters.Initialize
        
		Dim Query As String = ""
		Query = g_DataSource1.Query
        
		Dim WhereClause As StringBuilder
		Dim GroupByClause As StringBuilder
		Dim OrderByClause As StringBuilder
		WhereClause.Initialize
		GroupByClause.Initialize
		OrderByClause.Initialize
        
		Dim Counter As Int = 0
		For Each ColumnName As String In g_DataSource1.SearchColumns
			' WHERE-Klausel für Teilstring-Suche
			If Counter > 0 Then WhereClause.Append(" OR ")
			WhereClause.Append(ColumnName).Append(" LIKE ?")
			lstParameters.Add("%" & SearchText & "%")
            
			' GROUP BY für eindeutige Einträge
			If Counter > 0 Then GroupByClause.Append(", ")
			GroupByClause.Append(ColumnName)
            
			' ORDER BY für Treffer an erster Stelle
			If Counter > 0 Then OrderByClause.Append(", ")
			OrderByClause.Append("CASE WHEN ").Append(ColumnName).Append(" LIKE ? THEN 0 ELSE 1 END")
			lstParameters.Add(SearchText & "%") ' Treffer nur am Anfang
			Counter = Counter + 1
		Next
        
		' Finaler Query-Aufbau
		Query = Query & " WHERE " & WhereClause.ToString
		If GroupByClause.Length > 0 Then
			Query = Query & " GROUP BY " & GroupByClause.ToString
		End If
		Query = Query & " ORDER BY " & OrderByClause.ToString
        
		Log(Query)
        
		Dim DR As ResultSet = g_DataSource1.Database.ExecQuery2(Query, lstParameters)
        
		' Ergebnisse verarbeiten
		AS_SelectionList1.Clear
		AS_SelectionList1.SearchText = SearchText
		Do While DR.NextRow
			AS_SelectionList1.AddItem(DR.GetString(g_DataSource1.DisplayTextColumn), Null, DR.GetString(g_DataSource1.ValueColumn))
		Loop
		DR.Close
        
	End If
End Sub


#End Region

#Region Properties

Public Sub SetDataSource1(Database As SQL,Query As String,SearchColumns() As String,DisplayTextColumn As String,ValueColumn As String) As AS_AutoComplete_DataSource1
	g_DataSource1.Initialize
	g_DataSource1.Database = Database
	g_DataSource1.Query = Query
	g_DataSource1.SearchColumns = SearchColumns
	g_DataSource1.DisplayTextColumn = DisplayTextColumn
	g_DataSource1.ValueColumn = ValueColumn
	Return g_DataSource1
End Sub

'The Gap between the TextField and the top of the List
'Default: 5dip
Public Sub setTextField2ListGap(Gap As Float)
	m_TextField2ListGap = Gap
End Sub

Public Sub getTextField2ListGap As Float
	Return m_TextField2ListGap
End Sub

'How long should the TextChange event be ignored after an item has been clicked on?
'Should prevent the autocomplete from opening again as soon as the text is added to the text field
'Default: 1000 = 1 Second
Public Sub setAfterItemClickCoolDown(Duration As Long)
	m_AfterItemClickCoolDown = Duration
End Sub

Public Sub getAfterItemClickCoolDown As Long
	Return m_AfterItemClickCoolDown
End Sub

'Should the dialog close automatically when an item is clicked
'Default: True
Public Sub setAutoCloseOnItemClick(AutoClose As Boolean)
	m_AutoCloseOnItemClick = AutoClose
End Sub

Public Sub getAutoCloseOnItemClick As Boolean
	Return m_AutoCloseOnItemClick
End Sub

'Default: 5
Public Sub setMaxVisibleItems(MaxItems As Int)
	m_MaxVisibleItems= MaxItems
End Sub

Public Sub getMaxVisibleItems As Int
	Return m_MaxVisibleItems
End Sub

'The minimum number of matching characters required to trigger suggestions with highlighted matches
'Default: 2
Public Sub setSuggestionMatchCount(Count As Int)
	m_SuggestionMatchCount = Count
End Sub

Public Sub getSuggestionMatchCount As Int
	Return m_SuggestionMatchCount
End Sub

Public Sub setSearchTextHighlightedColor(Color As Int)
	AS_SelectionList1.SearchTextHighlightedColor = Color
End Sub

Public Sub getSearchTextHighlightedColor As Int
	Return AS_SelectionList1.SearchTextHighlightedColor
End Sub


#End Region

#Region Events

Private Sub ItemClicked(Item As AS_SelectionList_Item)
	m_IgnoreTextChange = True
	If xui.SubExists(mCallBack, mEventName & "_ItemClicked",1) Then
		CallSub2(mCallBack, mEventName & "_ItemClicked",Item)
	End If
	Sleep(m_AfterItemClickCoolDown)
	m_IgnoreTextChange = False
End Sub

#End Region

#Region ViewEvents

Private Sub AS_SelectionList1_SelectionChanged
	For Each Item As AS_SelectionList_Item In AS_SelectionList1.GetSelections
		ItemClicked(Item)
		If m_AutoCloseOnItemClick Then Close
		Exit
	Next
End Sub

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
	Dim parent As B4XView = view
	Do While parent.IsInitialized and parent <> m_RootPanel
		leftTop(0) = leftTop(0) + parent.Left
		leftTop(1) = leftTop(1) + parent.Top
		parent = parent.Parent
	Loop
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
