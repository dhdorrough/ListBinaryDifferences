unit BinaryDiffsMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

const
  OUTFILENAME = 'Differences';

type
  TfrmListBinaryDifferences = class(TForm)
    leFile1Name: TLabeledEdit;
    leFile2Name: TLabeledEdit;
    btnCompare: TButton;
    leOutputFileName: TLabeledEdit;
    lblStatus: TLabel;
    BtnBrowse1: TButton;
    btnBrowse2: TButton;
    btnBrowseOutput: TButton;
    btnCancel: TButton;
    cbDoAscii: TCheckBox;
    procedure btnCompareClick(Sender: TObject);
    procedure BtnBrowse1Click(Sender: TObject);
    procedure btnBrowse2Click(Sender: TObject);
    procedure btnBrowseOutputClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
    fCancel : boolean;
  public
    { Public declarations }
    Constructor Create(aOwner: TComponent); override;
  end;

var
  frmListBinaryDifferences: TfrmListBinaryDifferences;

implementation

uses MyUtils;

{$R *.dfm}

const
  MAX_DIFF_LEN = 255;

type
  THexBytes = packed array[0..MAX_DIFF_LEN] of byte;
  TDifference = record
                  DiffLen: integer;
                  File1Bytes: THexBytes;
                  File2Bytes: THexBytes;
                end;

procedure TfrmListBinaryDifferences.btnCompareClick(Sender: TObject);
type
  TBigBuf = array[0..MAXINT-1] of byte;
var
  FileSize1, FileSize2, FileSize, i: integer;
  Infile1, InFile2: file;
  OutFile: TextFile;
  Buf1, Buf2: ^TBigBuf;
  idx, DiffStart, DiffEnd, DiffLen, NrDifferences: integer;
  aDifference: TDifference;
  OK: boolean;
  OutputFileName: string;
  Temp: string;
{$R-}
  function NextDiff(StartIdx: integer): integer;
  var
    mode: TSearch_Type; // = (SEARCHING, SEARCH_FOUND, NOT_FOUND);
    idx: integer;
  begin { NextDiff }
    result := - 1;
    mode := SEARCHING;
    Idx  := StartIdx;
    repeat
      if idx >= FileSize then
        mode := NOT_FOUND
      else
        if Buf1[Idx] <> Buf2[idx] then
          begin
            mode := SEARCH_FOUND;
            result := idx
          end
        else
          inc(idx);
    until mode <> SEARCHING;
  end;  { NextDiff }

  function NextSame(StartIdx: integer): integer;
  var
    mode: TSearch_Type; // = (SEARCHING, SEARCH_FOUND, NOT_FOUND);
  begin { NextSame }
    result := -1;
    idx := StartIdx;
    mode := SEARCHING;
    repeat
      if idx >= FileSize then
        mode := NOT_FOUND
      else
        if (Buf1[Idx] = Buf2[idx]) and  // require 2 bytes to be the same 
           (Buf1[Idx+1] = Buf2[Idx+1]) then
          begin
            mode := SEARCH_FOUND;
            result := idx
          end
        else
          inc(idx);
    until mode <> SEARCHING;
  end;  { NextSame }

{$R+}
  function HexByteStr(NrBytes: integer; HexBytes: THexBytes; DoAscii: boolean): string;
  const
    PRINTABLE = [32{' '}..126{'~'}];
  var
    i: integer;
    chs: string2;
  begin { HexByteStr }
    result := '';
    for i := 0 to NrBytes-1 do
      begin
        if DoAscii then
          if HexBytes[i] in PRINTABLE then
            chs := chr(Hexbytes[i]) + ' '
          else
            chs := HexByte(HexBytes[i])
        else
          chs := HexByte(HexBytes[i]);

        result := result + ' ' + chs;
      end;
  end;  { HexByteStr }

begin
  FileSize1 := FileSize32(leFile1Name.Text);
  FileSize2 := FileSize32(leFile2Name.Text);

  OK := FileSize1 = FileSize2;
  if not OK then
    OK := YesFmt('FileSize1 (%d) <> FileSize2 (%d). Proceed anyway?', [FileSize1, FileSize2]);

  if OK then
      begin
        FileSize := Min(FileSize1, FileSize2);

        try
          AssignFile(InFile1, leFile1Name.Text);
          Reset(InFile1, FileSize);

          AssignFile(InFile2, leFile2Name.Text);
          Reset(InFile2, FileSize);
        except
          on e:Exception do
            begin
              Error(e.message);
              Exit;
            end;
        end;

        btnCancel.Visible := true;

        OutputFileName := leOutputFileName.Text;
        AssignFile(OutFile, OutputFileName);
        Rewrite(OutFile);

        WriteLn(OutFile, 'BINARY FILE DIFFERENCES @ ', DateTimeToStr(Now));
        WriteLn(OutFile, 'File #1: ', leFile1Name.Text);
        WriteLn(OutFile, 'File #2: ', leFile2Name.Text);
        WriteLn(OutFile);
        WriteLn(OutFile, '  #.     Addr:  Bytes      ');
        WriteLn(OutFile, '---.     ----:  -----      ');

        idx := 0;  NrDifferences := 0;
        try
          GetMem(Buf1, FileSize);
          GetMem(Buf2, FileSize);

          BlockRead(InFile1, Buf1^, 1);
          BlockRead(InFile2, Buf2^, 1);

          try
            repeat
              DiffStart := NextDiff(Idx);
              if DiffStart >= 0 then
                begin
                  DiffEnd   := NextSame(DiffStart);
                  if DiffEnd >= 0 then
                    begin
                      DiffLen := DiffEnd - DiffStart;
                      if DiffLen > 0 then
                        begin
                          if DiffLen > MAX_DIFF_LEN then
                            DiffLen := MAX_DIFF_LEN;
                          aDifference.DiffLen := DiffLen;
                          for i := 0 to DiffLen-1 do
                            begin
                              aDifference.File1Bytes[i] := Buf1[DiffStart+i];
                              aDifference.File2Bytes[i] := Buf2[DiffStart+i];
                            end;
                        end;
                      inc(NrDifferences);
                      lblStatus.Caption := Format('NrDifferences %4d: %10.0n/%10.0n',
                                                  [NrDifferences+1, DiffStart*1.0, FileSize*1.0]);
                      Application.ProcessMessages;
                      with aDifference do
                        begin
                          temp := Format('%8x', [DiffStart]);
                          if not cbDoAscii.Checked then
                            begin
                              WriteLn(OutFile, Format('%3d. %8s: %s', [NrDifferences, Temp,
                                                                       HexByteStr(DiffLen, File1Bytes, false)]));
                              WriteLn(OutFile, Format('%3s  %8s: %s', ['', '',
                                                                       HexByteStr(DiffLen, File2Bytes, false)]));
                            end
                          else
                            begin
                              WriteLn(OutFile, Format('%3d. %8s: %s', [NrDifferences, Temp,
                                                                       HexByteStr(DiffLen, File1Bytes, false)]));
                              WriteLn(OutFile, Format('%3s  %8s: %s', ['', '',
                                                                       HexByteStr(DiffLen, File1Bytes, true)]));
                              WriteLn(OutFile, Format('%3s  %8s: %s', ['', '',
                                                                       HexByteStr(DiffLen, File2Bytes, false)]));
                              WriteLn(OutFile, Format('%3s  %8s: %s', ['', '',
                                                                       HexByteStr(DiffLen, File2Bytes, true)]));
                            end;
                          WriteLn(OutFile);
                        end;
                      idx := idx + DiffLen;
                    end;
                end
            until (idx >= FileSize) or (DiffStart < 0) or (fCancel);
            lblStatus.Caption := Format('%d differences were found', [NrDifferences]);
            AlertFmt('%d differences were found', [NrDifferences]);
          finally
            FreeMem(Buf2);
            FreeMem(Buf1);
          end;
        finally
          CloseFile(OutFile);
          CloseFile(InFile2);
          CloseFile(InFile1);
          btnCancel.Visible := false;
          if not ExecAndWait('notepad.exe', OutputFileName, false) then
            AlertFmt('Could not edit "%s"', [OutputFileName]);
        end;
      end;
end;

constructor TfrmListBinaryDifferences.Create(aOwner: TComponent);
begin
  inherited;
  leOutputFileName.Text := UniqueFileName(ExtractFilePath(leOutputFileName.Text) + OUTFILENAME + YYYYMMDD(Now) + '.txt');
end;

procedure TfrmListBinaryDifferences.BtnBrowse1Click(Sender: TObject);
var
  FilePath: string;
begin
  FilePath := leFile1Name.Text;
  if BrowseForFile('File 1', FilePath, '*') then
    leFile1Name.Text := FilePath;
end;

procedure TfrmListBinaryDifferences.btnBrowse2Click(Sender: TObject);
var
  FilePath: string;
begin
  FilePath := leFile2Name.Text;
  if BrowseForFile('File 2', FilePath, '*') then
    leFile2Name.Text := FilePath;
end;

procedure TfrmListBinaryDifferences.btnBrowseOutputClick(Sender: TObject);
var
  FilePath: string;
begin
  FilePath := leOutputFileName.Text;
  if BrowseForFile('Output File', FilePath, '*') then
    leOutputFileName.Text := FilePath;
end;

procedure TfrmListBinaryDifferences.btnCancelClick(Sender: TObject);
begin
  fCancel := true;
end;

end.
