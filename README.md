# Compiler_Development_ITMO_2021

Compiler written in studying purposes.

Compiler is based on this grammar:
```
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
```

Сompiler supports:
1. Constructing AST
2. Producing simple ASM-like listing

### Running

Compiler is written in Flex/Bison/Scala. But since not everyone has that kind of enviroment I provide fat-jar.

Take fat-jar from the root:
```bash
java -jar compiler-assembly-0.1.jar <file to parse> <ast/asm/both>
```

### Test-case

test.aaa

```pascal
Var a, b, c, d;
Begin
a := 1;
b := 2;
c := -10;
d := a;
d := (a + c) * a / (c - 5);

{
    THIS IS A BIG TEST
    of comment block section
    d := 666;
}

While (b > ((c - a) * 2)) Do
Begin
c := c + 1;
End
End
```

Compiling:

```bash
java -jar compiler-assembly-0.1.jar test.aaa both
```

Result:

* AST graph:
```
 0| Root <- [ProgramStructural]
	 1| Variables Declaration <- [ProgramStructural]
		 2| Var <- [Keyword]
		 2| Variables list <- [Enumeration]
			 3| a <- [Identifier]
			 3| Variables list <- [Enumeration]
				 4| b <- [Identifier]
				 4| Variables list <- [Enumeration]
					 5| c <- [Identifier]
					 5| Variables list <- [Enumeration]
						 6| d <- [Identifier]
	 1| Program Description <- [ProgramStructural]
		 2| Operators <- [Enumeration]
			 3| Operator <- [Operator]
				 4| := <- [Assigment]
					 5| a <- [Identifier]
					 5| 1 <- [Const]
			 3| Operators <- [Enumeration]
				 4| Operator <- [Operator]
					 5| := <- [Assigment]
						 6| b <- [Identifier]
						 6| 2 <- [Const]
				 4| Operators <- [Enumeration]
					 5| Operator <- [Operator]
						 6| := <- [Assigment]
							 7| c <- [Identifier]
							 7| Expression <- [Expression]
								 8| 10 <- [Const]
								 8| -- <- [UnaryOp]
					 5| Operators <- [Enumeration]
						 6| Operator <- [Operator]
							 7| := <- [Assigment]
								 8| d <- [Identifier]
								 8| a <- [Identifier]
						 6| Operators <- [Enumeration]
							 7| Operator <- [Operator]
								 8| := <- [Assigment]
									 9| d <- [Identifier]
									 9| Expression <- [Expression]
										 10| Expression <- [Expression]
											 11| a <- [Identifier]
											 11| + <- [BinaryOp]
											 11| c <- [Identifier]
										 10| * <- [BinaryOp]
										 10| Expression <- [Expression]
											 11| a <- [Identifier]
											 11| / <- [BinaryOp]
											 11| Expression <- [Expression]
												 12| c <- [Identifier]
												 12| - <- [BinaryOp]
												 12| 5 <- [Const]
							 7| While <- [Keyword]
								 8| Expression <- [Expression]
									 9| b <- [Identifier]
									 9| > <- [BinaryOp]
									 9| Expression <- [Expression]
										 10| Expression <- [Expression]
											 11| c <- [Identifier]
											 11| - <- [BinaryOp]
											 11| a <- [Identifier]
										 10| * <- [BinaryOp]
										 10| 2 <- [Const]
								 8| Operators <- [Enumeration]
									 9| Operator <- [Operator]
										 10| := <- [Assigment]
											 11| c <- [Identifier]
											 11| Expression <- [Expression]
												 12| c <- [Identifier]
												 12| + <- [BinaryOp]
												 12| 1 <- [Const]
```

* ASM listing:
```asm
mov a 1
mov b 2
mov __tmp0 (- 10)
mov c __tmp0
mov d a
mov __tmp2 (a + c)
mov __tmp4 (c - 5)
mov __tmp3 (a / __tmp4)
mov __tmp1 (__tmp2 * __tmp3)
mov d __tmp1
__label_start_0:
mov __tmp7 (c - a)
mov __tmp6 (__tmp7 * 2)
mov __tmp5 (b > __tmp6)
jz __tmp5 __label_end_1
mov __tmp8 (c + 1)
mov c __tmp8
jmp __label_start_0
__label_end_1:
```
