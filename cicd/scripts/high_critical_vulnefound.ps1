          Write-Output "Vulnerabilities found, failing the build."
          Write-Output "`n"
          if ("${{ steps.check_vulnerabilities.outputs.highLevel }}" -eq "true"){
            Write-Output "HIGH Severity Vulnerabilities Found."
          }
          if ("${{ steps.check_vulnerabilities.outputs.criticalLevel }}" -eq "true"){
            Write-Output "CRITICAL Severity Vulnerabilities Found."
          }
          Write-Output "Check and update your packages to fix security."
          exit 1
