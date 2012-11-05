unit test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookActionHelper, Captcha, RUtils, Classes, SysUtils;

type

  { TTest }

  TTest = class(TBrookAction)
  public
    procedure Get(ARequest: TBrookRequest;
      {%H-}AResponse: TBrookResponse); override;
    procedure Post({%H-}ARequest: TBrookRequest;
      {%H-}AResponse: TBrookResponse); override;
  end;

const
  FORM =
    '<!DOCTYPE HTML>'+lf+
    '<html lang="pt-BR">'+lf+
    '<head>'+lf+
    '	<meta charset="UTF-8">'+lf+
    '	<title></title>'+lf+
    '</head>'+lf+
    '<body>'+lf+
    '<img src="data:image/gif;base64,%s"/>'+lf+
    '	<form action="%s" method="post">'+lf+
    '		<input type="text" name="captcha"/>'+lf+
    '		<input type="submit"/>'+lf+
    '	</form>'+lf+
    '</body>'+lf+
    '</html>';

implementation

uses
  FPWritePNG;

procedure TTest.Get(ARequest: TBrookRequest; AResponse: TBrookResponse);
var
  VImage: TMemoryImage;
  VStream: TMemoryStream;
begin
  if not TCaptcha.FontExists(ftLiberationSerifRegularTTF) then
    Exit;
  VImage := TMemoryImage.Create;
  VStream := TMemoryStream.Create;
  try
    SetCookie('captcha', TCaptcha.Generate(VStream));
    VStream.Position := 0;
    Write(FORM, [StreamToBase64(VStream), ARequest.ScriptName]);
  finally
    VStream.Free;
    VImage.Free;
  end;
end;

procedure TTest.Post(ARequest: TBrookRequest; AResponse: TBrookResponse);
begin
  if SameText(Fields['captcha'].AsString, GetCookie('captcha')) then
    Write('OK')
  else
    Write('Fail');
end;

initialization
  TTest.Register('*');

end.
