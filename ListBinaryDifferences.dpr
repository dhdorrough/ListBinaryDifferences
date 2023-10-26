program ListBinaryDifferences;

uses
  Forms,
  BinaryDiffsMain in 'BinaryDiffsMain.pas' {frmListBinaryDifferences},
  MyUtils in '..\MyUtils\MyUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmListBinaryDifferences, frmListBinaryDifferences);
  Application.Run;
end.
