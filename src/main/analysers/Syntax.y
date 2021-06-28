%language "Java"

%define api.parser.class {Syntax}
%define api.parser.public

%token CONSTANT
%token IDENTIFIER
%token ASSIGMENT_OPERATOR
%token SEMICOLON
%token PLUS MULTIPLY DIVIDE GREATER_OPERATOR LESS_OPERATOR EQUALS_OPERATOR
%token UNARY_MINUS
%token BINARY_MINUS
%token COMMA_SEPARATOR
%token START_BRACKET
%token END_BRACKET
%token WHILE_START
%token END_KEYWORD VAR_KEYWORD DO_KEYWORD BEGIN_KEYWORD
%token COMMENT

%type <Tree> program programDescription variablesDeclarations variables operators operator expression

%code {
	public Compiler compiler = new Compiler();
	AST ast = new AST(compiler);
}

/*
    <Программа> ::= <Объявление переменных> <Описание вычислений>
    <Описание вычислений> ::= Begin < Список операторов > End.
    <Объявление переменных> ::= Var <Список переменных>
    <Список переменных> ::= <Идент>; | <Идент> , <Список переменных> |
    <Идент> ; <Список переменных>
    <Список операторов> ::= <Оператор> | <Оператор> <Список операторов>
    <Оператор>::=<Присваивание> |<Сложный оператор>|<Составной оператор> 
    <Присваивание> ::= <Идент> := <Выражение> ;
    <Выражение> ::= <Ун.оп.><Подвыражение> | <Подвыражение>
    <Подвыражение> :: = ( <Выражение> ) | <Операнд> |
    < Подвыражение > <Бин.оп.> <Подвыражение>
    <Ун.оп.> ::= "-"
    <Бин.оп.> ::= "-" | "+" | "*" | "/" | "<" | ">" | "="
    <Операнд> ::= <Идент> | <Const>
    <Сложный оператор>:: =<Оператор цикла>|<Составной оператор>
    <Оператор цикла>:: = While <Выражение> Do <Оператор>
    <Составной оператор> ::= Begin <Список операторов> End
    <Идент> ::= <Буква> <Идент> | <Буква>
    <Const> ::= <Цифра> <Const> | <Цифра>
*/

%start program

%%

program:
    variablesDeclarations programDescription {
        Tree[] args = {$1, $2};
        $$ = ast.jcAddAstNode("Root", args);
    }
    ;

programDescription:
    BEGIN_KEYWORD operators END_KEYWORD { $$ = ast.jcAddAstNode("Program Description", $2); }
    ;

variablesDeclarations:
    VAR_KEYWORD variables {
        Tree[] args = {Tree.apply("Var"), $2};
        $$ = ast.jcAddAstNode("Variables Declaration", args);
    }
    ;

variables:
    IDENTIFIER SEMICOLON { $$ = ast.jcAddVariable(yyval.toString(), null); }
|   IDENTIFIER COMMA_SEPARATOR variables { $$ = ast.jcAddVariable(yyval.toString(), $3); }
|   IDENTIFIER SEMICOLON variables { $$ = ast.jcAddVariable(yyval.toString(), $3); }
    ;

expression:
    IDENTIFIER { $$ = ast.identifierRef(yyval.toString()); }
|   CONSTANT { $$ = ast.constantRef(yyval.toString()); }
|   START_BRACKET expression END_BRACKET { $$ = $2; }
|   UNARY_MINUS expression {
        Tree[] args = {$2, Tree.apply("--")};
        $$ = ast.jcAddAstNode("Expression", args);
    }
|   expression PLUS expression {
        Tree[] args = {$1, Tree.apply("+"), $3};
        $$ = ast.jcAddAstNode("Expression", args);
    }
|   expression MULTIPLY expression {
        Tree[] args = {$1, Tree.apply("*"), $3};
        $$ = ast.jcAddAstNode("Expression", args);
    }
|   expression DIVIDE expression {
        Tree[] args = {$1, Tree.apply("/"), $3};
        $$ = ast.jcAddAstNode("Expression", args);
    }
|   expression BINARY_MINUS expression {
        Tree[] args = {$1, Tree.apply("-"), $3};
        $$ = ast.jcAddAstNode("Expression", args);
    }
|   expression GREATER_OPERATOR expression {
        Tree[] args = {$1, Tree.apply(">"), $3};
        $$ = ast.jcAddAstNode("Expression", args);
    }
|   expression LESS_OPERATOR expression {
        Tree[] args = {$1, Tree.apply("<"), $3};
        $$ = ast.jcAddAstNode("Expression", args);
    }
|   expression EQUALS_OPERATOR expression {
        Tree[] args = {$1, Tree.apply("="), $3};
        $$ = ast.jcAddAstNode("Expression", args);
    }
    ;

operators:
    operator { $$ = $1; }
|   operator operators {
        Tree[] args = {$1, $2};
        $$ = ast.jcAddAstNode("Operators", args);
    }
    ;

operator:
    IDENTIFIER ASSIGMENT_OPERATOR expression SEMICOLON { $$ = ast.addAssigment(yyval.toString(), $3); }
|   BEGIN_KEYWORD operators END_KEYWORD { $$ = ast.jcAddAstNode("Operators", $2); }
|   WHILE_START expression DO_KEYWORD operator {
        Tree[] args = {$2, $4};
        $$ = ast.jcAddAstNode("While", args);
    }
   ;

%%