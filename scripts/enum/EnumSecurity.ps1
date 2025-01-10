# Enumerate security configuration
function Enum-Security {
    # languagemode
    # applocker policy
    # defender
    # amsi bypass
}

function Get-LanguageMode {
    $mode = $ExecutionContext.SessionState.LanguageMode;
    echo $mode;
}

function Get-ApplockerPolicy {
    # exe policy
    Get-Item -Path Registry::HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\SrpV2\Exe\
}
