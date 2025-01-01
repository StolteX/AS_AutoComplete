﻿B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Private TextField1 As B4XView
	Private AS_AutoComplete1 As AS_AutoComplete

	Dim sql1 As SQL

	Private AS_TextFieldAdvanced1 As AS_TextFieldAdvanced
	Private B4XFloatTextField1 As B4XFloatTextField
	
	#If B4A
	Dim ime As IME
	#End If
End Sub

Public Sub Initialize
	
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("frm_main")
	
	B4XPages.SetTitle(Me,"AS_AutoComplete Example")
	
	#If B4A
	ime.Initialize("ime")
	#End If
	
	xui.SetDataFolder("AS_AutoCompleteExample")
	Wait For (File.CopyAsync(File.DirAssets, "Countries.db", xui.DefaultFolder, "Countries.db")) Complete (Success As Boolean)
	Log("Success: " & Success)
	
	#If B4J
	sql1.InitializeSQLite(xui.DefaultFolder, "Countries.db",True)
	#Else
	sql1.Initialize(xui.DefaultFolder, "Countries.db",True)
	#End If
	
	
	
	
	
	AS_AutoComplete1.Initialize(Me,"AS_AutoComplete1",Root,B4XFloatTextField1.mBase)
	AS_AutoComplete1.SetDataSource1(sql1,"dt_Country","name","code")
	
	#If B4A
	TextField1.As(EditText).Background = BackGround(xui.Color_Black)
	#End IF
	AS_AutoComplete1.AutoCloseOnNoResults = True
	
End Sub

Private Sub B4XPage_Resize (Width As Int, Height As Int)
	AS_AutoComplete1.Resize(Width,Height)
End Sub

Private Sub B4XPage_KeyboardStateChanged (Height As Float)
	AS_AutoComplete1.KeyboardStateChanged(Height)
End Sub

#If B4A

Sub BackGround(Color As Int) As ColorDrawable
	Dim cdb As ColorDrawable

	cdb.Initialize(Color, 5dip)
	Return cdb
End Sub

#End If

'Private Sub AS_AutoComplete1_RequestNewData(SearchText As String)
'	
'	Dim lstItems As List
'	lstItems.Initialize
'	For i = 0 To 10 -1
'		lstItems.Add(AS_AutoComplete1.CreateItem("Test " & i,Null,i))
'	Next
'	
'	AS_AutoComplete1.SetNewData(lstItems)
'	
'End Sub



'Private Sub AS_AutoComplete1_RequestNewData(SearchText As String)
'	
'	Dim lstItems As List
'	lstItems.Initialize
'	For i = 0 To 10 -1
'		lstItems.Add(AS_AutoComplete1.CreateItem("Test " & i,Null,i))
'	Next
'	
'	AS_AutoComplete1.SetNewData(lstItems)
'	
'End Sub

Private Sub AS_TextFieldAdvanced1_TextChanged(Text As String)
	AS_AutoComplete1.TextChanged(Text)
End Sub

Private Sub TextField1_TextChanged (Old As String, New As String)
	AS_AutoComplete1.TextChanged(New)
End Sub

Private Sub B4XFloatTextField1_TextChanged (Old As String, New As String)
	AS_AutoComplete1.TextChanged(New)
End Sub