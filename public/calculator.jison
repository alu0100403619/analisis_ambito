/* description: Parses end executes mathematical expressions. */

%{

var symbolTables = [{ name: '', father: null, vars: {} }];
var scope = 0; 
var symbolTable = symbolTables[scope];
var symbol_table = {};

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

block
    : consts vars proclists statement
       {
          $1 ? c = $1 : c = 'NULL'
          //if ($1) c = $1;
          //else c = 'NULL';
          $2 ? v = $2 : v = 'NULL'
          $3 ? p = $3 : p = 'NULL'
          
           $$ = {
                type: 'BLOCK',
                consts: c,
                vars: v,
                procs: p,
                stat: $4
           };
       }
    ;

consts
    : /*empty*/
    | CONST assignment constlist ';'
       {
          cl = [$2];
          if ($3 && $3.length > 0)
             cl = cl.concat($3);
          $$ = {
             type: 'CONST',
             const_list: cl
          };
       }
    ;
    
constlist
    : /*empty*/
    | ',' assignment constlist
       {
          $$ = [$2];
          if ($3 && $3.length > 0)
             $$ = $$.concat($3);
       }
    ;

vars
    : /*empty*/
    | VAR ID varlist ';'
       {
          vl = [$2];
          if ($3 && $3.length > 0)
             vl = vl.concat($3);
          $$ = {
             type: 'VAR',
             var_list: vl
          };
       }
    ;
    
varlist
    : /*empty*/
    | ',' ID varlist
       {
          $$ = [$2];
          if ($3 && $3.length > 0)
             $$ = $$.concat($3);
       }
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
      {
         $$ = [$2]
         if ($3 && $3.length > 0)
             $$ = $$.concat($3);
      }
    ;
    
statement
    :  ID '=' expression
       {$$ = {
          type: $2,
          name: $1,
          right: $3,
          value: $3.value
        };
      }
    | CALL ID arguments
      {
         if (!symbol_table[$2])
            throw new Error("Don't exist the procedure or function "+$2);
         $$ = {
           type: $1,
           name: $2,
           arg: $3,
           value: symbol_table[$2]
         };
      }
    | BEGIN statement statementlist END
      {
         sl = [$2];
         if ($3 && $3.length > 0)
             sl = sl.concat($3);
         $$ = {
            type: $1,
            statement_list: sl
         };
      }
    | IF condition THEN statement
    | WHILE condition DO statement
    ;
    
statementlist
    : /*empty*/
    | ';' statement statementlist
       {
          $$ = [$2];
          if ($3 && $3.length > 0)
             $$ = $$.concat($3);
       }
    ;

condition
    : ODD expression
    | expression comparisson expression
    ;

comparisson
    : '==' {return yytext;}
    | '#' {return yytext;}
    | '<' {return yytext;}
    | '>=' {return yytext;}
    | '>' {return yytext;}
    | '>=' {return yytext;}
    ;
    
assignment
    : ID '=' number
      {
         //No reasigna el valor del simbolo en la tabla de simbolos
         //symbol_table[$1] = $$.value = $3.value;
         symbol_table[$1] = $3.value;
         $$ = {
            type: $2,
            left: $1,
            right: $3,
            //value: $3.value
         };
      }
    ;

number
    : NUMBER { $$ = {
                      type: 'NUMBER',
                      //value: parseInt(yytext) 
                      value: Number(yytext) 
                    };
             }
    ;
    
expression
    : ID '=' expression
         //{ symbol_table[$1] = $$ = $3; }        
      {
       //symbol_table[$1] = $$.value = $3.value;
         symbol_table[$1] = $3.value;
         $$ = {
            type: $2,
            left: $1,
            right: $3,
            value: $3.value
         };
      }
    | PI '=' expression 
         { throw new Error("Can't assign to constant 'π'"); }
    | E '=' expression 
         { throw new Error("Can't assign to math constant 'e'"); }
    | expression '+' expression
//         {$$ = $1+$3;}
      {
         $$ = {
            type: $2,
            left: $1,
            right: $3,
            value: $1.value + $3.value
         };
      }
    | expression '-' expression
//         {$$ = $1-$3;}
      {
         $$ = {
            type: $2,
            left: $1,
            right: $3,
            value: $1.value - $3.value
         };
      }
    | expression '*' expression
//         {$$ = $1*$3;}
      {
         $$ = {
            type: $2,
            left: $1,
            right: $3,
            value: $1.value * $3.value
         };
      }
    | expression '/' expression
      {
         if ($3.value == 0) throw new Error("Division by zero, error!");
         $$ = {
            type: $2,
            left: $1,
            right: $3,
            value: $1.value / $3.value
         };
      }
    | expression '^' expression
//         {$$ = Math.pow($1, $3);}
      {
         $$ = {
            type: $2,
            left: $1,
            right: $3,
            value: Math.pow($1.value, $3.value)
         };
      }
    | expression '!'
      {
         if ($1.value % 1 !== 0) 
              throw "Error! Attempt to compute the factorial of "+
                    "a floating point number "+$1;
         $$ = {
            type: $2,
            left: $1,
            value: fact($1.value)
         };
      }
    | expression '%'
//         {$$ = $1/100;}
      {
         $$ = {
            type: $2,
            left: $1,
            right: $3,
            value: $1.value/100
         };
      }
    | '-' expression %prec UMINUS
         {$$ = {
            type: 'MINUS',
            value: -$2.value
         };}
    | '(' expression ')'
         {$$ = $2;}
    | number
         {$$ = $1;} 
    | E
         //{$$ = Math.E;}
         {$$ = {name: $1, value: Math.E};}
    | PI
         //{$$ = Math.PI;}
         {$$ = {name: $1, value: Math.PI};}
    | ID 
//         { $$ = symbol_table[yytext] || 0; }        
      {$$ = {name: $1, value: symbol_table[$1]};}
    ;
