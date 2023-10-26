object frmListBinaryDifferences: TfrmListBinaryDifferences
  Left = 613
  Top = 218
  Width = 697
  Height = 273
  Caption = 'List Binary Differences'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    681
    234)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 32
    Top = 201
    Width = 40
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblStatus'
  end
  object leFile1Name: TLabeledEdit
    Left = 32
    Top = 32
    Width = 545
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 56
    EditLabel.Height = 13
    EditLabel.Caption = 'File 1 Name'
    TabOrder = 0
    Text = 'c:\temp\File1.vol'
  end
  object leFile2Name: TLabeledEdit
    Left = 32
    Top = 88
    Width = 545
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 56
    EditLabel.Height = 13
    EditLabel.Caption = 'File 2 Name'
    TabOrder = 1
    Text = 'c:\temp\File2.vol'
  end
  object btnCompare: TButton
    Left = 576
    Top = 201
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Compare'
    Default = True
    TabOrder = 2
    OnClick = btnCompareClick
  end
  object leOutputFileName: TLabeledEdit
    Left = 32
    Top = 144
    Width = 545
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 82
    EditLabel.Height = 13
    EditLabel.Caption = 'Output File Name'
    TabOrder = 3
    Text = 'C:\TEMP\FileDiffs.TXT'
  end
  object BtnBrowse1: TButton
    Left = 592
    Top = 32
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 4
    OnClick = BtnBrowse1Click
  end
  object btnBrowse2: TButton
    Left = 592
    Top = 88
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 5
    OnClick = btnBrowse2Click
  end
  object btnBrowseOutput: TButton
    Left = 592
    Top = 144
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 6
    OnClick = btnBrowseOutputClick
  end
  object btnCancel: TButton
    Left = 472
    Top = 200
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 7
    Visible = False
    OnClick = btnCancelClick
  end
  object cbDoAscii: TCheckBox
    Left = 32
    Top = 176
    Width = 97
    Height = 17
    Caption = 'Do Ascii'
    TabOrder = 8
  end
end
