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

## Private Rpc
- only owner can connect to private rpc url
- only owner can send transaction to public mempool via private rpc url
- to send private transaction, send directly to miners instead to mempool
  [https://docs.alchemy.com/reference/eth-sendprivatetransaction](private-tx)


  ## AMM - Automated Market Maker
  - tokenA * tokenB = K ( this constant K will always stay the same when multiply tokenA * tokenB )
  - AMM uses formula constant product automated market maker, X * Y = K (constant)
  - supply 100,000 tokenA * 50,000 tokenB, which mean 100,000 tokenA * 50,000 tokenB = 5 billion
  - when someone buys a 500 tokenA, he will get 5 billion / 100,500 = 49.751 ( 50,000 - 49.751 = 249 tokenB );
  - which mean user that buy 500 tokenA will get 249 tokenB in return after calculation 

  ### Price Calculation
  - if each of token A worth $2, then total of them will be $200,000
  - and if each of token B worth $4, then total will be $200,000
  - calculation goes like, $200,000 / amount of token A or b left in the liquidity pool ( $200,000 / 100,500 = $1.9, drop from $2 )
  - if a liquidity amount is small, it will impact the price really much
  - if a liq pool amount is large, then it wont impact the price too much

  ## Liquidity Pool
  - liq pool provider
  - routing trade
  - trade fee goes to liq pool provider
  - the more people add a liqiduity, the less u will get ur fee cut
  - the amount of both assets to add to liq pool shoud be 50:50 worth in $$ ($100,000 tokenA + $100,000 tokenB), 
  - for example, theres 50,000 tokenA, each of them worth $2, so the total will be $100,000
  - and 100,000 tokenB, each of them worth $1, so it will be $100,000 as well 
  ( tokenA 50,000 ($100,000) + tokenB 100,000 ($100,000) = $200,000 ) 50:50 ratio

  ## Lending & Borrowing Protocol
  - user deposit funds, and borrow some token on the protocol
  - user needs to deposit more than they want to borrow ( overcollaterized ), ex: user can only borrow of 80% of what they deposit.
  - if they dont pay back, their funds will be liquidate it. or their funds/collateral prices are passes under collateral (below collateral threshold (80%))