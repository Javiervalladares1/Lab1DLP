#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "== Inciso 1: identificadores Java =="
flex java_identifiers.l
gcc lex.yy.c -o java_identifiers_scanner
./java_identifiers_scanner tests/identificadores_input.txt

echo
echo "== Incisos 2-5: lexer completo =="
flex lab1_lexer.l
gcc lex.yy.c -o lab1_scanner
./lab1_scanner tests/lab1_input.txt

echo
echo "== Inciso 6: prueba en JavaScript =="
./lab1_scanner tests/test_javascript.js
