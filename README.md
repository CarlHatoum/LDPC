# LDPC

## Introduction
Fonctions MATLAB implémentant un décodeur LDPC (voir https://fr.wikipedia.org/wiki/LDPC).

- SOFT_DECODER.m implémente le mode de décision dit "soft decoding".
- HARD_DECODER.m implémente le mode de décision dit "hard decoding".

## Exemple d'usage
Prenons l'exemple donné dans le [PDF](https://github.com/CarlHatoum/LDPC/blob/master/ldpc.pdf) : On a le mot code : c = [1 0 0 1 0 1 0 1].
Une fois transmis, une erreur est introduite, c1 passe de 0 à 1. Nous recevons donc c = [1 1 0 1 0 1 0 1] et nous souhaitons retrouver le mot code original.

Dans un premier temps, déclarer les variables suivantes dans le SHELL MATLAB:

- c,  un vecteur colonne de taille N contenant des valeurs binaires du mot code à décoder.
```
>> c = [1; 1; 0; 1; 0; 1; 0; 1]

c =

     1
     1
     0
     1
     0
     1
     0
     1
```    
- H,  une  matrice  de  taille  [M,N],  qui est  la  matrice  de  parité. Elle  est constituée de 0 et 1 logiques, ou de true et false.
```
>> H = [false true false true true false false true; true true true false false true false false; false false true false false true true true; true false false true true false true false]

H =
     4×8 logical array

     0     1     0     1     1     0     0     1
     1     1     1     0     0     1     0     0
     0     0     1     0     0     1     1     1
     1     0     0     1     1     0     1     0
```
- *Pour la fonction SOFT_DECODER,* une variable supplémentaire p, un vecteur colonne, de même dimension que c.  Les valeurs pi sont les probabilités que le bit ci soit un "1".
```
>> p = [0.9; 0.2; 0.1; 0.8; 0.2; 0.8; 0.1; 0.9]

p =

    0.9000
    0.2000
    0.1000
    0.8000
    0.2000
    0.8000
    0.1000
    0.9000
```

- MAX_ITER, le nombre maximal d'itérations que l'algorithme pourra exécuter.
```
>> MAX_ITER = 100

MAX_ITER =

   100
```
Lancer  ensuite  la  fonction  MATLAB HARD_DECODER_GROUPE3 ou SOFT_DECODER_GROUPE3 avec  les paramètres dans l'ordre suivant :
```
>> HARD_DECODER_GROUPE3(c, H, MAX_ITER)
```
ou
```
>> SOFT_DECODER_GROUPE3(c, H, p, MAX_ITER)
```

Deux cas se distinguent:
- Si le mot est décodé avec la limité d'itérations autorisé, un message s'affichera indiquant que l'algorithme a réussi en un nombre x d'étapes, et retournera le mot décodé.
- Dans le cas contraire, l'algorithme va retourner un message informant que  la  limite  d'itérations  a  été  atteinte. Le  mot  code  retourné  par  la fonction s'affichera aussi mais n'est bon dans aucun des cas.

Dans notre cas, nous obtenons :
```
Parity check completed successfully after 2 iterations.

ans =

     1
     0
     0
     1
     0
     1
     0
     1
```
Qui correspond bien au mot code sans erreur.
## Release History

* 0.0.1
    * Work in progress

## Meta
Auteurs : [Carl Hatoum](https://https://github.com/CarlHatoum), [Alexandros Sidiras Galante](https://github.com/Ratatinator97), Maxime Michel, Quentin Tixeront.

## Contributing

1. Fork it (<https://github.com/yourname/yourproject/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request
