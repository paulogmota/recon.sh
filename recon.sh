#!/bin/bash

: '
Todo: 
- tmux
- httpx
- subfinder
- katana
- anew
- feroxbuster
- paramspider
- waybackurls
- qsreplace
- templates privados 
- nuclei
- baixar leakypaths.txt
- shcheck.py
- tmux - criar id para cada sessão
- uro
'

echo -n "Domínio alvo: "
read target

raiz=/root/pentest/
caminho=/root/pentest/$target

mkdir $caminho 2> /dev/null

# Subdomains + HTTPX
#subfinder -silent -d "$target" --all -o $caminho/subs.txt
#cat $caminho/subs.txt | httpx -o $caminho/httpx.txt
#cat $caminho/subs.txt | httpx -td -title -o $caminho/tech-detect.txt


# Dir Bruteforce - leaky-paths.txt
#cat $caminho/httpx.txt | feroxbuster --stdin --no-state -a 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36' -w $raiz/leaky-paths.txt -s 200,403 -k -o $caminho/leaky.txt

# Dir Bruteforce - big.txt
cat $caminho/httpx.txt | feroxbuster -x php,jsp,asp,aspx,html --stdin --no-state -a 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36' -w $raiz/big.txt -s 200,403 -k -o $caminho/big.txt

cat $caminho/httpx.txt | httpx -silent -sc 200 | feroxbuster --stdin --no-state -a 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36' -w $raiz/big.txt -k -o $caminho/big.txt

# Tratamento
# remover/filtrar via URO: .gif, svg, jpg, css, png
cat $caminho/leaky.txt $caminho/big.txt | grep 200 | awk '{print $NF}' | uro -b gif svf jpg css png | anew $caminho/urls-200.txt
cat $caminho/leaky.txt $caminho/big.txt | grep 403 | awk '{print $NF}' | uro -b gif svf jpg css png | anew $caminho/urls-403.txt

rm $caminho/leaky.txt $caminho/big.txt

# Crawlers.txt
## katana
cat $caminho/urls-200.txt | katana -d 10 -rl 100 | anew $caminho/katana.txt
cat $caminho/katana.txt | uro | anew $caminho/crawlers.txt; rm $caminho/katana.txt
## wayback
cat $caminho/httpx.txt | waybackurls | anew $caminho/wayback.txt
cat $caminho/wayback.txt | httpx -silent -mc 200 | anew $caminho/crawlers.txt; rm $caminho/wayback.txt
## paramspider

# Reflected xss - qsreplace + airixss

# Basic Nuclei - nuclei-templates + privados


