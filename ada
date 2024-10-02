[1mdiff --git a/.github/workflows/codacy.yml b/.github/workflows/codacy.yml[m
[1mindex 9e81977..51fdbc6 100644[m
[1m--- a/.github/workflows/codacy.yml[m
[1m+++ b/.github/workflows/codacy.yml[m
[36m@@ -8,13 +8,14 @@[m [mon:[m
     branches:[m
       - main[m
 [m
[31m-permissions:[m
[31m-  issues: write[m
[31m-  contents: read[m
[31m-[m
 jobs:[m
   build:[m
     runs-on: ubuntu-latest[m
[32m+[m[32m    strategy:[m
[32m+[m[32m      fail-fast: false[m
[32m+[m[32m      matrix:[m
[32m+[m[32m        python-version: ['3.10', '3.11', '3.12'][m
[32m+[m
     services:[m
       mysql:[m
         image: mysql:5.7[m
[36m@@ -34,7 +35,7 @@[m [mjobs:[m
     - name: Set up Python[m
       uses: actions/setup-python@v5[m
       with:[m
[31m-        python-version: '3.12'[m
[32m+[m[32m        python-version: ${{matrix.python-version}}[m
 [m
     - name: Install dependencies[m
       run: |[m
[36m@@ -44,87 +45,14 @@[m [mjobs:[m
     - name: Check for outdated dependencies[m
       run: |[m
           pip list --outdated > outdated_dependencies.txt[m
[31m-      [m
[32m+[m[41m    [m
     - name: Show outdated dependencies[m
       run: cat outdated_dependencies.txt[m
 [m
[31m-    - name: Audit dependencies for security issues[m
[31m-      id: audit[m
[32m+[m[32m    - name: Security audit with pip-audit[m
       run: |[m
         pip install pip-audit[m
[31m-        pip-audit -o audit_report.json --format json || true[m
[31m-    [m
[31m-    - name: Show audit report[m
[31m-      run: |[m
[31m-        if [ -f audit_report.json ]; then[m
[31m-            cat audit_report.json[m
[31m-        else[m
[31m-             echo "No se encontró audit_report.json."[m
[31m-        fi[m
[31m-    [m
[31m-    - name: Prepare notification[m
[31m-      run: |[m
[31m-            # Leer dependencias obsoletas[m
[31m-            if [ -f outdated_dependencies.txt ]; then[m
[31m-                outdated=$(awk 'NR>2 {print $1, $2, $3}' outdated_dependencies.txt | tr '\n' ';')[m
[31m-            else[m
[31m-                outdated="No se encontraron dependencias obsoletas."[m
[31m-            fi[m
[31m-      [m
[31m-            # Leer vulnerabilidades desde el archivo JSON[m
[31m-            if [ -f audit_report.json ]; then[m
[31m-                vulnerabilities=$(cat audit_report.json)[m
[31m-            else[m
[31m-                vulnerabilities="No se encontraron vulnerabilidades."[m
[31m-            fi[m
[31m-      [m
[31m-            echo "outdated_dependencies=$outdated" >> $GITHUB_ENV[m
[31m-            echo "vulnerabilities=$vulnerabilities" >> $GITHUB_ENV[m
[31m-    [m
[31m-    - name: Create GitHub issue for outdated dependencies and vulnerabilities[m
[31m-      uses: actions/github-script@v6[m
[31m-      with:[m
[31m-        github-token: ${{ secrets.GITHUB_TOKEN }}[m
[31m-        script: |[m
[31m-                const title = "Notificación de Dependencias";[m
[31m-                [m
[31m-                // Formatear dependencias obsoletas en tabla[m
[31m-                const outdatedDeps = process.env.outdated_dependencies[m
[31m-                  .split(';')[m
[31m-                  .filter(dep => dep.trim())[m
[31m-                  .map(dep => `| ${dep.split(' ').join(' | ')} |`)[m
[31m-                  .join('\n');[m
[31m-          [m
[31m-                const outdatedTable = `| Paquete | Versión instalada | Nueva versión |\n|---------|------------------|---------------|\n${outdatedDeps || '| No se encontraron dependencias obsoletas |'}`;[m
[31m-          [m
[31m-                // Procesar vulnerabilidades y construir tabla[m
[31m-                const vulnerabilitiesData = JSON.parse(process.env.vulnerabilities);[m
[31m-                const vulnerableDeps = vulnerabilitiesData.dependencies.filter(dep => dep.vulns.length > 0);[m
[31m-          [m
[31m-                const vulnerabilityTable = vulnerableDeps.length > 0 [m
[31m-                  ? vulnerableDeps.map(dep => [m
[31m-                      dep.vulns.map(vuln => [m
[31m-                        `| ${dep.name} | ${dep.version} | ${vuln.id} | ${vuln.fix_versions || 'No disponible'} |`[m
[31m-                      ).join('\n')[m
[31m-                    ).join('\n')[m
[31m-                  : '| No se encontraron vulnerabilidades |';[m
[31m-          [m
[31m-                const vulnsTable = `| Nombre | Versión | ID | Versión de arreglo |\n|--------|---------|----|--------------------|\n${vulnerabilityTable}`;[m
[31m-          [m
[31m-                const body = `[m
[31m-                  ### Dependencias obsoletas:[m
[31m-                  ${outdatedTable}[m
[31m-                  [m
[31m-                  ### Vulnerabilidades encontradas:[m
[31m-                  ${vulnsTable}[m
[31m-                `;[m
[31m-          [m
[31m-                await github.rest.issues.create({[m
[31m-                  owner: context.repo.owner,[m
[31m-                  repo: context.repo.repo,[m
[31m-                  title: title,[m
[31m-                  body: body[m
[31m-                });[m
[32m+[m[32m        pip-audit || true[m
   [m
     - name: Upload coverage to Codacy[m
       run: |[m
