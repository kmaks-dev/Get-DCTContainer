[CmdletBinding(ConfirmImpact="Medium",
# DefaultParameterSetName=<String>,
# HelpURI=<URI>,
SupportsPaging=$False,
SupportsShouldProcess=$False,
PositionalBinding=$False)]

Param (
    [Parameter(Mandatory=$true)]
    [string]$Container
)

Begin {
}

Process {
    $Answer = Invoke-WebRequest -Uri "https://dctgdansk.pl/strefa-klienta/sprawdz-kontener-on-line/" `
    -Method "POST" `
    -Headers @{
    "method"="POST"
    "authority"="dctgdansk.pl"
    "scheme"="https"
    "path"="/strefa-klienta/sprawdz-kontener-on-line/"
    "cache-control"="max-age=0"
    "origin"="https://dctgdansk.pl"
    "upgrade-insecure-requests"="1"
    "dnt"="1"
    "user-agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.102 Safari/537.36"
    "accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
    "sec-fetch-site"="same-origin"
    "sec-fetch-mode"="navigate"
    "sec-fetch-user"="?1"
    "sec-fetch-dest"="document"
    "referer"="https://dctgdansk.pl/strefa-klienta/sprawdz-kontener-on-line/"
    "accept-encoding"="gzip, deflate, br"
    "accept-language"="pl-PL,pl;q=0.9,en-US;q=0.8,en;q=0.7"
    "cookie"="secure; qtrans_front_language=pl; acceptCookie=yes; Secure"
    } `
    -ContentType "application/x-www-form-urlencoded" `
    -Body "cntrnumber=$Container&submit=Sprawd%C5%BA";

    If($Answer -Match '<h3>Nic nie znaleziono</h3>') { 
        Return "Nie znaleziono kontenera"
    }
    
    $XmlTable = [xml]($Answer -split '\n' -join '' -replace '.*(<table class="container">.*</table>).*','$1' -replace '&nbsp;')

    $XmlTable.table.tr | ForEach-Object {
        [PSCustomObject]@{
        Name = ($PSItem.td | Where-Object class -eq "name")."#text"
        Value = ($PSItem.td | Where-Object class -eq "value")."#text"
        }
    }
}

End {}