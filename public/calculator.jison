/* description: Parses end executes mathematical expressions. */

%{

var symbolTables = [{ name: '', father: null, vars: {} }];
var scope = 0; 
var symbolTable = symbolTables[scope];

function getScope() {
  return scope;
}

function getFormerScope() {
   scope--;
   symbolTable = symbolTables[scope];
}

function makeNewScope(id) {
   scope++;
   symbolTable.vars[id].symbolTable = symbolTables[scope] =  { name: id, father: symbolTable, vars: {} };
   symbolTable = symbolTables[scope];
   return symbolTable;
}

function fact (n){ 
  return n==0 ? 1 : fact(n-1) * n 
}

function odd (n) {
   return (n%2)==0 ? 1 : 0
}

%}

%token PROCEDURE CALL BEGIN END IF THEN WHILE DO
%token ID E PI EOF CONST VAR NUMBER DOT

/* operator associations and precedence */
%right '='
%left '+' '-'
%left '*' '/'
%left '^'
%right '%'
%left UMINUS
%left '!'

%right THEN ELSE

%start program

%% /* language grammar */

program
    : block DOT EOF
        { 
          $$ = $1; 
          //console.log($$);
          //return [$$, symbol_table];
          return $$;
        }
    ;

/*block
    : consts
    | vars
    | proclists statement
    ;*/

block
    : consts vars proclists statement
    ;

consts
    : /*empty*/
    | CONST assignment constlist ';'
    ;
    
constlist
    : /*empty*/
    | ',' assignment constlist
    ;

vars
    : /*empty*/
    | VAR ID varlist ';'
    ;
    
varlist
    : /*empty*/
    | ',' ID varlist
    ;

proclists
    : /*empty*/
    | decl_proc arguments ';' block ';' proclists
    ;

decl_proc
    : PROCEDURE ID //makeNewScope
    ;
    
arguments
    : /*empty*/
    | '(' ID varlist ')'
    ;
    
statement
    :  ID '=' expression
    | CALL ID arguments
    | BEGIN statement statementlist END
    | IF condition THEN statement
    | WHILE condition DO statement
    ;
    
statementlist
    : /*empty*/
    | ';' statement statementlist
    ;

condition
    : ODD expression
    | expression COMPARISSON expression
    ;

assignment
    : ID '=' NUMBER
    ;
    
expression
    : ID '=' expression
//         { symbol_table[$1] = $$ = $3; }        
     | PI '=' expression 
//         { throw new Error("Can't assign to constant 'π'"); }
     | E '=' expression 
//         { throw new Error("Can't assign to math constant 'e'"); }
     | expression '+' expression
//         {$$ = $1+$3;}
     | expression '-' expression
//         {$$ = $1-$3;}
     | expression '*' expression
//         {$$ = $1*$3;}
     | expression '/' expression
//         {
//           if ($3 == 0) throw new Error("Division by zero, error!");
//           $$ = $1/$3;
//         }
     | expression '^' expression
//         {$$ = Math.pow($1, $3);}
     | expression '!'
//         {
//           if ($1 % 1 !== 0) 
//              throw "Error! Attempt to compute the factorial of "+
//                    "a floating point number "+$1;
//           $$ = fact($1);
//         }
     | expression '%'
//         {$$ = $1/100;}
     | '-' expression %prec UMINUS
//         {$$ = -$2;}
     | '(' expression ')'
//         {$$ = $2;}
     | NUMBER
//         {$$ = Number(yytext);} 
     | E
//         {$$ = Math.E;}
     | PI
//         {$$ = Math.PI;}        
     | ID 
//         { $$ = symbol_table[yytext] || 0; }        
     ;
