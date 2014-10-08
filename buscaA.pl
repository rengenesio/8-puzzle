%Implementa��o da Busca A*

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Este programa tem como objetivo calcular o caminho �timo entre um estado final e um inicial. Para isso, o usu�rio deve
% antes executar o programa gera.pl para gerar a pattern database. Feito isso, o usu�rio deve chamar buscaA(S, G), aonde 
% S � a configura��o inicial do problema e G � o estado final aonde se deseja chegar (deve obrigatoriamente ser igual ao
% passado no gera.pl. Ao terminar a execu��o, o programa mostrar� o caminho �timo de S at� G, usando uma busca A*.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% buscaA(+Start, +Goal) - carrega o arquivo com as heur�sticas, adiciona uma cl�usula que diz que o custo do g do estado inicial Start � 0. Chama a busca A* expandindo o n� Start, at� chegar ao objetivo Goal.
buscaA(S, G) :- carregaBanco, heuristica(G, 0), tamanho(S, Ts), tamanho(G, Tg),  Ts = Tg, not(h(S, 0)), assert(g(S, 0)), writef("Calculando solu��o... isso por levar alguns minutos...\n"), expande(G, S, [S], [S], []), !.
buscaA(_, G) :- not(heuristica(G, 0)), writef("Estado final n�o � igual ao usado para gerar a pattern database!\n"), !.
buscaA(S, _) :- h(S, 0), writef("Estado inicial j� � solu��o!\n").


% carrega o arquivo com as heur�sticas pdb.pl para consulta.
carregaBanco :- consult(pdb), !.

% Calcula o F do n� N, que � a soma entre o custo (G) e a heuristica (H).
f(N, F) :- g(N, G), h(N, H), F is G + H, !.

% Calcula pela pattern database qual n� X casa com a lista L. Se casar, a heur�stica de L � a mesma de X.
h(L, H) :- heuristica(X, H), casa(L, X), !.

% expande(Goal, Selecionado, Fronteira, Visitados, Expandidos) - expande o n� selecionado da fronteira (de acordo com o menor custo f) at� achar o n� Goal (encontrou a solu��o) ou at� a fronteira estar vazia (n�o encontrou a solu��o). Como a heur�stica a ser usada � �tima, s� ser�o expandidos os n�s que levam � solu��o �tima, logo a lista Expandidos representar� o caminho �timo.
expande(_, _, [], _, _) :- writef("N�o h� solu��o!\n"), !.
expande(Goal, Selecionado, _, _, Expandidos) :- casa(Selecionado, Goal), concatena(Expandidos, Selecionado, Solucao), writef("Solu��o de "), g(Selecionado, G), write(G), writef(" passos:\n"), imprime(Solucao),!.
% seleciona-se o n� na fronteira que tenha o menor custo f (custo g + h). Remove-se este n� da fronteira, gerando uma nova fronteira Fronteira2. Anda-se em todas as dire��es gerando n�s (apenas quando for poss�vel andar em alguma dire��o e estes n�s gerados ainda n�o forem n�s j� visitados). Adiciona-se este n� � lista dos n�s j� visitados Visitados e � fronteira. Adiciona cl�usulas que indicam o custo G de cada um dos n�s gerados (G do pai + 1). Chama-se recursivamente a expans�o de mais um n� na nova fronteira.
expande(Goal, Selecionado, Fronteira, Visitados, Expandidos) :- delete(Fronteira, Selecionado, Fronteira2), cima(Selecionado, Visitados, Cima), baixo(Selecionado, Visitados, Baixo), esq(Selecionado, Visitados, Esq), dir(Selecionado, Visitados, Dir), concatena(Visitados, Cima, Visitados2), concatena(Visitados2, Baixo, Visitados3), concatena(Visitados3, Esq, Visitados4), concatena(Visitados4, Dir, Visitados5), concatena(Fronteira2, Cima, Fronteira3), concatena(Fronteira3, Baixo, Fronteira4), concatena(Fronteira4, Esq, Fronteira5), concatena(Fronteira5, Dir, Fronteira6), concatena(Expandidos, Selecionado, Expandidos2), g(Selecionado, C), C2 is C + 1, assert(g(Cima, C2)), assert(g(Baixo, C2)), assert(g(Esq, C2)), assert(g(Dir, C2)), seleciona(Fronteira6, Selecionado2), expande(Goal, Selecionado2, Fronteira6, Visitados5, Expandidos2), !.

% seleciona(+L, N) - seleciona o n� N de menor custo F em L.
% Caso base: selecionar um n� em uma lista com s� 1 elemento � selecionado este elemento.
seleciona([], []) :- !.
seleciona([A], A) :- !.
% selecionar um n� em uma lista com mais de 1 elemento, � comparar o custo da cabe�a da lista F1 com o custo do menor elemento da cauda da lista. Se F1 for menor, A ser� selecionado. Sen�o, o menor da cauda da lista � que ser� o selecionado.
seleciona([A|B], A) :- seleciona(B, Menor2), f(A, F1), f(Menor2, F2), F1 < F2, !.
seleciona([_|B], Menor2) :- seleciona(B, Menor2).

% concatena(+L1, +L2, -L3) - adiciona L2 ao final de L1, gerando L3. Se L2 for vazia, n�o adiciona
concatena(A, [], A) :- !.
concatena(A, B, C) :- append(A, [B], C), !.

% cima(+L1, +V, -L2) - anda com o branco para cima na configura��o L1, gerando L2
% V� a posi��o do branco em L1 e armazena em B. Calcula o lado do tabuleiro e armazena em N. LB � a linha aonde o branco est� (come�ando em 0). Para que seja poss�vel andar, LB > 0. CB � a coluna onde est� o branco. O elemento a ser trocado com o branco � o que est� na mesma coluna, mas 1 linha acima do branco. Calcula-se a posi��o P do elemento na lista e efetua a troca do branco com o elemento acima dele.
cima(L1, Visitados, L2) :- nth1(B, L1, b), tamanho(L1, T), N is integer(sqrt(T)), LB is (B-1) // N, LB > 0, CB is (B-1) mod N, LP is LB - 1, P is CB + (LP * N) + 1, troca(L1, B, P, L2), not(member(L2, Visitados)), !.
% Se L2 j� � um estado pertencente a V (visitados) ou n�o � poss�vel andar para cima, retorna lista vazia.
cima(_, _, []) :- !.

% baixo(+L1, +V, -L2) - anda com o branco para baixo na configura��o L1, gerando L2
% V� a posi��o do branco em L1 e armazena em B. Calcula o lado do tabuleiro e armazena em N. LB � a linha aonde o branco est� (come�ando em 0). Para que seja poss�vel andar, LB < (N-1). CB � a coluna onde est� o branco. O elemento a ser trocado com o branco � o que est� na mesma coluna, mas 1 linha abaixo do branco. Calcula-se a posi��o P do elemento na lista e efetua a troca do branco com o elemento acima dele.
baixo(L1, Visitados, L2) :- nth1(B, L1, b), tamanho(L1, T), N is integer(sqrt(T)), LB is (B-1) // N, LB < (N-1), CB is (B-1) mod N, LP is LB + 1, P is CB + (LP * N) + 1, troca(L1, B, P, L2), not(member(L2, Visitados)), !.
% Se L2 j� � um estado pertencente a V (visitados) ou n�o � poss�vel andar para baixo, retorna lista vazia
baixo(_, _, []) :- !.

% esq(+L1, +V, -L2) - anda com o branco para esquerda na configura��o L1, gerando L2.
% V� a posi��o do branco em L1 e armazena em B. Calcula o lado do tabuleiro e armazena em N. CB � a coluna aonde o branco est� (come�ando em 0). Para que seja poss�vel andar, CB > 0. LB � a linha onde est� o branco. O elemento a ser trocado com o branco � o que est� na mesma linha, mas 1 coluna � esquerda do branco. Calcula-se a posi��o P do elemento na lista e efetua a troca do branco com o elemento acima dele.
esq(L1, Visitados, L2) :- nth1(B, L1, b), tamanho(L1, T), N is integer(sqrt(T)), CB is (B-1) mod N, CB > 0, LB is (B-1) // N, CP is CB - 1, P is CP + (LB * N) + 1, troca(L1, B, P, L2), not(member(L2, Visitados)), !.
% Se L2 j� � um estado pertencente a V (visitados) ou n�o � poss�vel andar para esquerda, retorna lista vazia
esq(_, _, []) :- !.

% dir(+L1, +V, -L2) - anda com o branco para direita na configura��o L1, gerando L2.
% V� a posi��o do branco em L1 e armazena em B. Calcula o lado do tabuleiro e armazena em N. CB � a coluna aonde o branco est� (come�ando em 0). Para que seja poss�vel andar, CB < (N-1). LB � a linha onde est� o branco. O elemento a ser trocado com o branco � o que est� na mesma linha, mas 1 coluna � direita do branco. Calcula-se a posi��o P do elemento na lista e efetua a troca do branco com o elemento acima dele.
dir(L1, Visitados, L2) :- nth1(B, L1, b), tamanho(L1, T), N is integer(sqrt(T)), CB is (B-1) mod N, CB < (N-1), LB is (B-1) // N, CP is CB + 1, P is CP + (LB * N) + 1, troca(L1, B, P, L2), not(member(L2, Visitados)), !.
% Se L2 j� � um estado pertencente a V (visitados) ou n�o � poss�vel andar para direita, retorna lista vazia.
dir(_, _, []) :- !.

% tamanho(+L, -T) - retorna T que � o n�mero de elementos que L tem
% Caso base: lista vazia tem tamanho 0.
tamanho([], 0) :- !.
% Tamanho da lista � o tamanho da sua cauda + 1.
tamanho([_|Y], T) :- tamanho(Y, T1), T is T1+1, !.

% troca(+L1, +P1, +P2, -L2) - troca em L1 os elementos da posi��o P1 e P2 entre si, vendo que Ex � o elemento que est� na posi��o Px. Retorna L2 com os elementos trocados
troca(L1, P1, P2, L2) :- nth1(P1, L1, E1), nth1(P2, L1, E2), troca2(L1, P1, E1, P2, E2, 1, L2), !.

% troca2(+L1, +P1, +E1, +P2, +E2, -L2) - troca em L1 os elementos E1 e E2 das posi��es P1 e P2 respectivamente, entre si.
% Caso base: trocar qualquer par de elementos em qualquer posi��o em uma lista vazia, retorna lista vazia.
troca2([], _, _, _, _, _, []) :- !.
% Percorre-se a lista, adicionando 1 a 1 os elementos na lista de sa�da, at� chegar na posi��o P1 ou P2. Chegando em P1, escreve-se E2 na lista de sa�da e em P2, escreve-se E1.
troca2([A|B], P1, E1, P2, E2, I, [A|L]) :- I \= P1, I \= P2, J is I+1, troca2(B, P1, E1, P2, E2, J, L), !.
troca2([_|B], P1, E1, P2, E2, I, [E1|L]) :- I = P2, J is I+1, troca2(B, P1, E1, P2, E2, J, L), !.
troca2([_|B], P1, E1, P2, E2, I, [E2|L]) :- I = P1, J is I+1, troca2(B, P1, E1, P2, E2, J, L), !.

% casa(+L1, +L2) - verifica se a lista L1 (lista que n�o tem asteriscos) casa com L2 (lista que pode ter asteriscos). Usado para o caso em que o usu�rio quer um estado final com asteriscos.
% Caso base: lista vazia casa com lista vazia.
casa([], []).
% [A|B] casa com [C|D] se A for igual a C e as caudas das listas casarem.
casa([A|B], [C|D]) :- A = C, casa(B, D), !.
% [_|B] casa com [C|D] se C for asterisco e as caudas das listas casarem.
casa([_|B], [C|D]) :- C = *, casa(B, D), !.

% imprime(+L) - imprime na tela para o usu�rio o caminho �timo
% Caso base: lista com apenas 1 elemento n�o tem caminho.
imprime([_]) :- writef("Obs: andar para X significa andar com o espa�o em branco na dire��o X\n").
% verifica a dire��o em que andou e dependendo, escreve um texto para o usu�rio.
imprime([A, B|C]) :- cima(A, [], B), writef("Anda pra cima, gera:     \n"), tamanho(B, T), T2 is sqrt(T), T3 is integer(T2), imprimeN(B, T3, 0), imprime([B|C]).
imprime([A, B|C]) :- baixo(A, [], B), writef("Anda pra baixo, gera:    \n"), tamanho(B, T), T2 is sqrt(T), T3 is integer(T2), imprimeN(B, T3, 0), imprime([B|C]).
imprime([A, B|C]) :- esq(A, [], B), writef("Anda pra esquerda, gera: \n"), tamanho(B, T), T2 is sqrt(T), T3 is integer(T2), imprimeN(B, T3, 0), imprime([B|C]).
imprime([A, B|C]) :- dir(A, [], B), writef("Anda pra direita, gera:  \n"), tamanho(B, T), T2 is sqrt(T), T3 is integer(T2), imprimeN(B, T3, 0), imprime([B|C]).

% imprimeN(L, N, I) - imprime uma lista L num formato de N elementos por linha, usando I como um iterador. Se o elemento a ser imprimido for um 'b' (que representa o espa�o em branco), imprime um espa�o em branco.
imprimeN([], _, _) :- writef("\n\n"), !.
imprimeN([A|B], N, I) :- I2 is I + 1, I \= N, A \= b, write(A), writef("   "), imprimeN(B, N, I2), !.
imprimeN([_|B], N, I) :- I2 is I + 1, I \= N, writef("    "), imprimeN(B, N, I2), !.
imprimeN(L, N, _) :- writef("\n"), imprimeN(L, N, 0), !.