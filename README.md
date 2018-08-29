# Example of Simple algebraic data types for C

C言語でも代数データ型を使ってパターンマッチを使ったプログラムが書きたい。
とりあえずシンプルなものでもいい。そう思って探してみたところ、[Simple algebraic data types for C](https://research.utwente.nl/en/publications/simple-algebraic-data-types-for-c-2) というものを見つけました。

論文などもあるのですが、使い方がよくわかりませんでした。
ということで、四則演算をするだけのプログラムを作りました。

## install & make & run

gcc flex bison をインストールしてください。

    $ make
    $ ./calc
    :
    :
    ./calc

    1  : EADD( l=
    2  :  EMUL( l=
    3  :   EINT( v=2 ),r=
    4  :   EINT( v=2 ) ),r=
    5  :  EMUL( l=
    6  :   EINT( v=4 ),r=
    7  :   ESUB( l=
    8  :    EINT( v=5 ),r=
    9  :    EINT( v=1 ) ) ) )
    2*2+4* ( 5 - 1 ) 
    = 20

このように表示されれば成功です。

## 説明

adt ディレクトリ内に代数的データ型の定義を展開するadt.exeのソースがあります。
adt.exeはcalc.adtをcalc.hおよびcalc.cを生成します。

    %{
      :
    %}
    expr
      = EINT(long v)
      | EADD(expr *l, expr *r)
      | ESUB(expr *l, expr *r)
      | EMUL(expr *l, expr *r)
      | EDIV(expr *l, expr *r);
    %{
      :
    %}

のようなプログラムは

    typedef	enum { EINT=1, EADD=2, ESUB=3, EMUL=4, EDIV=5 } expr_tag ;

    typedef	struct expr_struct {
      expr_tag tag ;
      int flag ;
      union {
        struct expr_struct **_binding ;
        struct {
          long _v ;
        } _EINT ;
        struct {
          struct expr_struct *_l ;
          struct expr_struct *_r ;
        } _EADD ;
        struct {
          struct expr_struct *_l ;
          struct expr_struct *_r ;
        } _ESUB ;
        struct {
          struct expr_struct *_l ;
          struct expr_struct *_r ;
        } _EMUL ;
        struct {
          struct expr_struct *_l ;
          struct expr_struct *_r ;
        } _EDIV ;
      } data ;
    } expr ;

というunion定義に変換されまた、


    expr *mkEINT( long _v );
    expr *mkEADD( expr *_l, expr *_r ) ;
    :

というような生成関数などが生成されます。

パターンマッチ用のマクロも生成されます:

    #define csEINT( _expr_, v ) \
      case EINT : \
        v = _expr_->data._EINT._v ;
    #define csEADD( _expr_, l, r ) \
      case EADD : \
        l = _expr_->data._EADD._l ; \
        r = _expr_->data._EADD._r ;
    :

これらのマクロを利用するには

    static long eval(expr *e) {
      long v;
      expr *l, *r;
      switch (e->tag) {
      csEINT(e,v)   return v;
      csEADD(e,l,r) return eval(l) + eval(r);
      csESUB(e,l,r) return eval(l) - eval(r);
      csEMUL(e,l,r) return eval(l) * eval(r);
      csEDIV(e,l,r) return eval(l) / eval(r);
      }
    }

というように記述することで単純なパターンマッチが動かせるようになります。

せっかくなので、パーサもbisonを用いて生成してみます:

    prog    : expr          { root = $1; }
    expr    : term          { $$ = $1; }
            | expr '+' term { $$ = mkEADD($1,$3); }
            | expr '-' term { $$ = mkESUB($1,$3); }
    term    : fact          { $$ = $1; }
            | term '*' fact { $$ = mkEMUL($1,$3); }
            | term '/' fact { $$ = mkEDIV($1,$3); }
    fact    : INT           { $$ = mkEINT($1); }
            | '(' expr ')'  { $$ = $2; }

詳細は省きましたが、以上のような文法定義からパーサが生成できます。


    void prexpr( int indent, expr *subject ) ;
    void fdexpr( expr **subject ) ;

印字(prexpr)、メモリ解放(fdexpr)を行う関数も生成されるので便利です。
