# Set application theme based on AppsUseLightTheme prefrence
$theme = @("#ffffff","#202020","#323232")
if (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme"){
    $theme = @("#292929","#f3f3f3","#fbfbfb")
}

# Enable all controls in selected page & disable the rest
function pageswap {
    (Compare-Object $pages $args[0]).InputObject | % {
        Write-Host "Attemping to Disable:" $_.Text
        if ($_.LocationPrev -eq $null){
            Add-Member -InputObject $_ -NotePropertyName LocationPrev -NotePropertyValue $_.Location -Force
        }
        $_.Location = New-Object System.Drawing.Size(999,999)
    }
    foreach ($item in $args[0]){
        if ($item.LocationPrev -ne $null){
            Write-Host "Attemping to Enable:" $item.Text
            $item.Location = $item.LocationPrev
        }
    }
}

# GUI Specs
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
$form = New-Object System.Windows.Forms.Form
$form.Text = "Pageswitcher"
$form.StartPosition = "CenterScreen"
$form.ClientSize = New-Object System.Drawing.Point(800,430)
$form.ForeColor = $theme[0]
$form.BackColor = $theme[1]
$tooltip = New-Object System.Windows.Forms.ToolTip

$list = New-Object System.Windows.Forms.ListBox
$list.Text = "ListBox"
$list.Size = New-Object System.Drawing.Size(300,300)
$list.Location = New-Object System.Drawing.Size(15,60)
$list.SelectionMode = "MultiExtended"
$list.DisplayMember = "Display"
$list.ForeColor = $theme[0]
$list.BackColor = $theme[1]

$button = New-Object System.Windows.Forms.Button
$button.Text = "Disable Selected Packages"
$button.Size = New-Object System.Drawing.Size(160,30)
$button.Location = New-Object System.Drawing.Size(30,20)
$button.FlatStyle = "0"
$button.FlatAppearance.BorderSize = "0"
$button.BackColor = $theme[2]

$next = New-Object System.Windows.Forms.Button
$next.Text = "Next"
$next.Size = New-Object System.Drawing.Size(140,40)
$next.Location = New-Object System.Drawing.Size(630,380)
$next.FlatStyle = "0"
$next.FlatAppearance.BorderSize = "0"
$next.BackColor = $theme[2]

$previous = New-Object System.Windows.Forms.Button
$previous.Text = "Previous"
$previous.Size = New-Object System.Drawing.Size(140,40)
$previous.Location = New-Object System.Drawing.Size(460,380)
$previous.FlatStyle = "0"
$previous.FlatAppearance.BorderSize = "0"
$previous.BackColor = $theme[2]

$dropdown = New-Object System.Windows.Forms.ComboBox
$dropdown.Text = "Select DNS Server"
$dropdown.Items.AddRange(@("dns.adguard.com","security.cloudflare-dns.com","dns.quad9.net"))

# Set Page Variables & Add Controls
$homepage = ($next,$dropdown)
$other = ($button,$previous)
$something = ($list,$next)
$pages = ($homepage,$other,$something)
$form.Controls.AddRange(@($list,$button,$next,$previous,$dropdown))

# Set Default Page to Homepage
pageswap $homepage

# Button Functions
$button.Add_Click{pageswap $something}
$next.Add_Click{
    pageswap $other
    Write-Host "`nSelected:" $dropdown.SelectedItem `n
    if ($dropdown.Text -ne "Select DNS Server"){
            Write-Host "`nSelected:" $dropdown.Text `n
    }
}
$previous.Add_Click{pageswap $homepage}

$form.ShowDialog()