#!/bin/bash

echo "Cleaning up"

rm src/main/java/Syntax.java
rm src/main/java/Lexer.java

echo ""
echo "Compiling Bison"

bison src/main/analysers/Syntax.y
mv Syntax.java src/main/java

echo ""
echo "Compiling Flex/Lex"

jflex src/main/analysers/Lexer.flex
mv src/main/analysers/*.java src/main/java