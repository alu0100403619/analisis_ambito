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
%token ID E PI EOF CONST VAR NUMBER

/* operator associations and precedence */
%right '='
%left '+' '-'
%left '*' '/'
//%left '^'
//%right '%'
//%left UMINUS
//%left '!'

%right THEN ELSE

%start program

%% /* language grammar */

program
    : block '.' EOF
        { 
          $$ = $1; 
          //console.log($$);
          //return [$$, symbol_table];
          return $$;
        }
    ;

block
    : consts
    | vars
    | proclists statement
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
    //: /*empty*/
    : ID '=' expression
    | CALL ID
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
    
expression
    : '+' term expressionlist
    | '-' term expressionlist
    ;

expressionlist
    : /*empty*/
    | '+' term expressionlist
    | '-' term expressionlist
    ;

term
    : factor termlist
    ;
    
termlist
    : /*empty*/
    | '*' factor termlist
    | '/' factor termlist
    ;
    
assignment
    : ID '=' NUMBER
    ;

factor
    : '(' expression ')'
    | ID
    | NUMBER
    ;
//--------------------------------------------------------------
// expressions
//     : s
//     | expressions ';' s
//     ;
// 
// s
//     : /* empty */
//     | e
//     ;
// 
// e
//     : ID '=' e
//         { symbol_table[$1] = $$ = $3; }        
//     | PI '=' e 
//         { throw new Error("Can't assign to constant 'π'"); }
//     | E '=' e 
//         { throw new Error("Can't assign to math constant 'e'"); }
//     | e '+' e
//         {$$ = $1+$3;}
//     | e '-' e
//         {$$ = $1-$3;}
//     | e '*' e
//         {$$ = $1*$3;}
//     | e '/' e
//         {
//           if ($3 == 0) throw new Error("Division by zero, error!");
//           $$ = $1/$3;
//         }
//     | e '^' e
//         {$$ = Math.pow($1, $3);}
//     | e '!'
//         {
//           if ($1 % 1 !== 0) 
//              throw "Error! Attempt to compute the factorial of "+
//                    "a floating point number "+$1;
//           $$ = fact($1);
//         }
//     | e '%'
//         {$$ = $1/100;}
//     | '-' e %prec UMINUS
//         {$$ = -$2;}
//     | '(' e ')'
//         {$$ = $2;}
//     | NUMBER
//         {$$ = Number(yytext);} 
//     | E
//         {$$ = Math.E;}
//     | PI
//         {$$ = Math.PI;}        
//     | ID 
//         { $$ = symbol_table[yytext] || 0; }        
//     ;
