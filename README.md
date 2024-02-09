## CLAMM
 - clamm => concentrated liquidity automated market maker
 - in uniswap V2 the price is calculated by amount of token0 divided by amount of token1


 ### Uniswap Pricing Calculation
 - token X * token Y = K => K is a constant value from tokenX * tokenY
 - constant K will always be the same
 - when someone selling X token they will get Y token
 - calculation will be X token + DX token (is token X that we selling) ( which mean liquidity pool of token X increased) 
 - and Y token - DY token (token Y that we buy) (which mean the amount of Y token will decrease inside liq pool);

 - DY calculation  
  1. Y - DY = K / (X + DX)
  2. DY = Y - K / (X + DX)
   = (yx + ydx - xy) / (x + dx)
   = ydx / (x + dx)
   uniswap has 0.3% trade fee
   dy = y * 0.997 * dx / (x + 0.997 * dx) 


## Liquidity
 - how much token to add to liq pool
  - uniswap liq pool will only take as much as possible to preserve the pool
  - reserves token A in liq pool call r_a (reserve a)
  - reserves token A in liq pool cal r_b (reserve b)
  - token A to add to liq pool call a
  - token B to add to liq pool call b
  - when liq added, r_a + a' and r_b + b'
  - if a' = a, then b >= b' or equal to r_b / r_a * a
  - if b' = b, then a >= a' or equal to r_a / r_b * b