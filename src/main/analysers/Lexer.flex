import java.lang.String;
import java.util.ArrayList;

%%

%class Lexer
%implements Syntax.Lexer
%standalone
%line
%column
%state unaryMinus, binaryMinus

%{
    private Object yylval;

    public Object getLVal() {
        return yylval;
    }

    public void yyerror(String message) {
        System.err.printf("LEXER -> %s: %s\t\t\t%d:%d\n", message, yytext(),(yyline + 1), (yycolumn + 1));
    }

    private void keywordsCheck(String lexem, int line, int symbol) {
        String[] words = {"End", "Var", "Do", "Begin", "While"};

        for (int i = 0; i < words.length; i++) {
            if (words[i].equalsIgnoreCase(lexem)) {
                System.err.printf("LEXER -> Unknown lexem: '%s' ('%s'?)\t\t\t%d:%d\n", lexem, words[i], line, symbol);
                break;
            }
        }
    }
%}

Comment = \{([\w\W]*?)\}
Keyword = "End" | "Var" | "Do" | "Begin"
Semicolon = ";"
Comma = ","
AssigmentSymbol = ":="
BinaryOperator = "+" | "*" | "/" | ">" | "<" | "="
MinusSymbol = "-"
Constant = [0-9]+
Identifier = [a-zA-Z]+
Whitespaces = [ \s]
BracketStart = "("
BracketEnd = ")"
WhileStart = "While"

%%

{Comment} {
    yylval = new String(yytext());
}

{Keyword} {
    yylval = new String(yytext());
    switch (yytext()) {
        case "Var" : return Syntax.Lexer.VAR_KEYWORD;
        case "Do" : return Syntax.Lexer.DO_KEYWORD;
        case "End" : return Syntax.Lexer.END_KEYWORD;
        case "Begin" : return Syntax.Lexer.BEGIN_KEYWORD;
    }
}

{WhileStart} {
    yylval = new String(yytext());
    yybegin(unaryMinus);
    return Syntax.Lexer.WHILE_START;
}

{Semicolon} {
    yylval = new String(yytext());
    return Syntax.Lexer.SEMICOLON;
}

{Comma} {
    yylval = new String(yytext());
    return Syntax.Lexer.COMMA_SEPARATOR;
}

{BracketEnd} {
    yylval = new String(yytext());
    return Syntax.Lexer.END_BRACKET;
}

{AssigmentSymbol} {
    yylval = new String(yytext());
    yybegin(unaryMinus);
    return Syntax.Lexer.ASSIGMENT_OPERATOR;
}

{BracketStart} {
    yylval = new String(yytext());
    yybegin(unaryMinus);
    return Syntax.Lexer.START_BRACKET;
}

{BinaryOperator} {
    yylval = new String(yytext());
    yybegin(unaryMinus);

    switch (yytext()) {
        case "+" : return Syntax.Lexer.PLUS;
        case "*" : return Syntax.Lexer.MULTIPLY;
        case "/" : return Syntax.Lexer.DIVIDE;
        case ">" : return Syntax.Lexer.GREATER_OPERATOR;
        case "<" : return Syntax.Lexer.LESS_OPERATOR;
        case "=" : return Syntax.Lexer.EQUALS_OPERATOR;
    }
}

<unaryMinus> {
    {MinusSymbol} {
        yylval = new String(yytext());
        yybegin(unaryMinus);
        return Syntax.Lexer.UNARY_MINUS;
    }
}

<binaryMinus> {
    {MinusSymbol} {
        yylval = new String(yytext());
        return Syntax.Lexer.BINARY_MINUS;
    }
}

{Constant}  {
    yylval = new Integer(yytext());
    yybegin(binaryMinus);
    return Syntax.Lexer.CONSTANT;
}

{Identifier} {
    keywordsCheck(yytext(), yyline+1, yycolumn);
    yylval = new String(yytext());
    yybegin(binaryMinus);
    return Syntax.Lexer.IDENTIFIER;
}

{Whitespaces} {}// Nothing here ¯\_(ツ)_/¯

. {
    System.out.printf("LEXER -> Unexpected token: '%s'\t\t\t%d:%d\n", yytext(), yyline+1, yycolumn);
    System.exit(0);
}