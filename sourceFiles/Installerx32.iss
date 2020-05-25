; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#include <C:\Program Files (x86)\Inno Download Plugin\idp.iss>

#define MyAppName "Charitas"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Charitas.co"
#define MyAppURL "https://charitas.co"
#define MyAppExeName "Charitas.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId=charitas-win-32-bit-arch
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AppContact=Charitas.co
DefaultDirName={userdesktop}\..\{#MyAppName}
UsePreviousAppDir=no
DefaultGroupName={#MyAppName}
UninstallDisplayName={#MyAppName}
AllowNoIcons=yes
SourceDir=..\x32Compiled
LicenseFile=..\sourceFiles\LICENSE
OutputBaseFilename=Charitas-INSTALLER-x32
OutputDir=..\releases
SetupIconFile=..\sourceFiles\favicon.ico
WizardStyle=modern
BackColor=$14AFEC
BackColor2=$12A0EC
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}";

[Files]
;PowerShell installers, to be used by [Code]
Source: "resources\app\miner\pscoreCheck.bat"; DestDir: "{tmp}"; Flags: dontcopy nocompression

;App stuff
Source: "Charitas.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\resources"


[Code]
var 
  ResultCode: Integer;
  Response: Boolean;
  PowershellResultCode: Integer;
  NeedsPowershell: Boolean;
  AgreedToPowershell: Boolean;
  PowershellAcceptPage: TInputOptionWizardPage;
  PowershellInstallPage: TOutputProgressWizardPage;
  PowershellPage: TOutputMsgWizardPage;

function DetectPowershell(): Integer;
begin
  NeedsPowershell := False;
  ExtractTemporaryFile('pscoreCheck.bat');
  if Exec(ExpandConstant('{tmp}\pscoreCheck.bat'), '', '', SW_HIDE, ewWaitUntilTerminated, PowershellResultCode) then
  begin
    if PowershellResultCode = 0 then 
    begin
    //pwsh works
    //don't do anything
    Result := 0;
    NeedsPowershell := False;
    end
    else if PowershellResultCode = 1 then 
    begin
    //pwsh doesn't work
    //install it
    NeedsPowershell := True;
    Result := 1;
    end
    else 
    begin
    //idk what else it could return
    Result := PowershellResultCode;
    MsgBox('Error detecting PowerShell version with return code ' + IntToStr(PowershellResultCode)+#13#13+'Please reach out to us on social media or email us at help@charitas.co.', mbInformation, MB_OK);
    end
  end 
  else begin
    MsgBox('Error: Could not detect PowerShell version, Error Code ' + IntToStr(PowershellResultCode)+ #13#13 +'Please reach out to us on social media or email us at help@charitas.co.', mbInformation, MB_OK);
    Result := PowershellResultCode;
  end
end;

function UserNeedsPowerShell(): Boolean;
begin
  Result := DetectPowershell = 1;
end; 

procedure InitializeWizard();
begin
  if IsX64 
  then
  begin
    MsgBox('You are trying to install the 32-bit version on a 64-bit system!'#13#13'While this will still run, it is highly recommended for performance that you download the correct version at https://charitas.co.', mbInformation, MB_OK);
  end;
  if DetectPowershell = 1 then 
  begin
    PowershellAcceptPage := CreateInputOptionPage(
      wpLicense,
      'Install PowerShell Core',
      'PowerShell Core was not detected. This is a requirement to install Charitas',
      'Install PowerShell Core from Microsoft?',
      True,
      False
    );

    PowershellAcceptPage.Add('&Yes, Install PowerShell Core');
    PowershellAcceptPage.Add('&No, do not install PowerShell Core (This will exit the installation).');
    PowershellAcceptPage.Values[0] := True;

    idpAddFile('https://github.com/PowerShell/PowerShell/releases/download/v7.0.1/PowerShell-7.0.1-win-x86.msi', ExpandConstant('{tmp}\PowerShellCorex86.msi'));
    idpDownloadAfter(PowershellAcceptPage.ID);

    PowershellInstallPage := CreateOutputProgressPage('Installing PowerShell Core', '');

    PowershellPage := CreateOutputMsgPage(
      wpSelectDir,
      'Charitas Information',
      'Charitas is a cryptocurrency mining program.', 
      'This means that occasionally, as Charitas installs mining software, your antivirus software may flag some files as a false positive, due to the nature of cryptocurrency mining software. We assure you that Charitas is completely safe, and that no files we include will maliciously impact your computer. For more information, visit our website or contact us at help@charitas.co.'
    );
  end
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (CurPageID > 1) then
  begin
    if (NeedsPowershell) and (not PowershellAcceptPage.Values[0]) then
    begin
      MsgBox('You must install PowerShell Core to use Charitas.', mbInformation, MB_OK);
      Result := False;
      WizardForm.Close();
      Abort();
    end;
    if (NeedsPowershell) and (CurPageID = PowershellPage.ID) then
    begin
      PowershellInstallPage.SetText('Extracting PowerShell Core. This may take some time.', '');
      PowershellInstallPage.SetProgress(2,10);
      PowershellInstallPage.Show;
      try
        if not Exec('msiexec.exe', ExpandConstant('/package {tmp}\PowerShellCorex86.msi'), '', SW_SHOW, ewWaitUntilTerminated, ResultCode) then
        begin
          MsgBox('Error Code : ' + IntToStr(ResultCode), mbInformation, MB_OK);
        end;
        BringToFrontAndRestore();
        PowershellInstallPage.SetProgress(10,10);
        Sleep(100);
      finally 
        PowershellInstallPage.Hide();
      end
    end;
    if (CurPageID = wpSelectTasks) then
    begin
      if not ShellExec('', 'pwsh.exe', '-Command Write-Output "PowerShell Core was installed successfully."', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      begin
        if not (ResultCode = 0) then begin
          MsgBox('Powershell was not installed correctly or was interrupted while installing. Please try again.', mbInformation, MB_OK);
          Result := False;
        end
      end
    end
  end
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  case CurUninstallStep of
    usUninstall:
      //Pre-Uninstall
      begin
        if not Exec(ExpandConstant('{app}\resources\app\miner\killAllOpen.bat'), '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then 
        begin
          MsgBox('ERROR: Could not verify that miners have closed before uninstalling. Please reach out to us on social media or at help@charitas.co'#13#10'Error Code: '+IntToStr(ResultCode), mbInformation, MB_OK);
          ShellExec('open', 'mailto:help@charitas.co', '', '', SW_SHOW, ewNoWait, ResultCode);
          Response := MsgBox('Continue Uninstalling?', mbConfirmation, MB_YESNO) = idYes;
          if Response = False then Abort(); 
        end
      end;
    usPostUninstall:
      // Post-Uninstall
      begin
          Exec('cmd.exe', '/c del "%userprofile%\Start Menu\Programs\Startup\charitasStartup.lnk"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      end;
  end;
end;