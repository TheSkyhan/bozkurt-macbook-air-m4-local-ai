#!/usr/bin/env python3
"""Sınırlı aritmetik; eval veya kod yürütme kullanmaz."""
import ast,json,operator,math,sys
OPS={ast.Add:operator.add,ast.Sub:operator.sub,ast.Mult:operator.mul,ast.Div:operator.truediv,ast.FloorDiv:operator.floordiv,ast.Mod:operator.mod,ast.Pow:operator.pow}
def calculate(expression):
    if len(expression)>300:raise ValueError('İfade çok uzun.')
    tree=ast.parse(expression,mode='eval')
    if len(list(ast.walk(tree)))>100:raise ValueError('İfade çok karmaşık.')
    def value(n):
        if isinstance(n,ast.Constant) and type(n.value) in (int,float):v=n.value
        elif isinstance(n,ast.UnaryOp) and isinstance(n.op,(ast.USub,ast.UAdd)):
            v=value(n.operand)*(-1 if isinstance(n.op,ast.USub) else 1)
        elif isinstance(n,ast.BinOp) and type(n.op) in OPS:
            a,b=value(n.left),value(n.right)
            if isinstance(n.op,ast.Pow) and abs(b)>100:raise ValueError('Üs sınırı 100.')
            v=OPS[type(n.op)](a,b)
        else:raise ValueError('Yalnız sayılar, parantez ve + - * / // % ** desteklenir.')
        if type(v) not in (int,float) or abs(v)>1e100 or not math.isfinite(v):raise ValueError('Sonuç sınır dışında.')
        return v
    return value(tree.body)
if __name__=='__main__':
    try:print(json.dumps({'ifade':sys.argv[1],'sonuc':calculate(sys.argv[1])},ensure_ascii=False))
    except Exception as e:print(json.dumps({'hata':str(e)},ensure_ascii=False));sys.exit(1)
