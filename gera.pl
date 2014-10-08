% Geração do banco de dados de padrões (heurísticas da Busca A*)

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Este programa tem como objetivo fazer uma pattern database de heurística para um problema do n-puzzle. O usuário ao 
% carregar este programa, deve chamar gera(L), aonde L é uma lista que representa o estado final do problema. A lista 
% tem que ter tamanho quadrado e possuir um caracter 'b' (sem aspas) para representar o espaço em branco do tabuleiro. 
% Feito isso, o programa vai gerar as heurísticas e gravá-las no arquivo "pdb.pl". Ao terminar, o usuário deverá executar 
% o programa "buscaA.pl" para ver a melhor sequência de passos de um estado inicial para o final. A cada chamada gera(L), 
% as heurísticas encontradas até então são apagadas.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% gera(+L) - abre o arquivo "pdb.pl" para escrita, troca-se os asteriscos por 'a' na lista, adiciona-se o custo de L como 0 (estado final tem estimativa 0) e chama-se a busca em largura com L na fronteira e como estado visitado. Ao final da busca, fecha o arquivo aberto.
gera(L) :- member(b, L), tamanho(L, T), quadrado(T), writef("Gerando a pattern database... por favor aguarde!\n"), tell('pdb.pl'), adiciona(L, 0), expande([L], [L]), told, writef("Terminado. Execute agora o arquivo buscaA.pl.\n"), !.
gera(L) :- member(b, L), writef("Configuração final de tamanho inválido. Tente de novo.\n"), !.
gera(_) :- writef("Configuração final não indica a posição do espaço em branco (b).\n").

% expande(+F, +V) - expande o nó que é a cabeça da fronteira F e adiciona seus filhos ao final de F (busca em largura). Anota todos os estados já visitados em V para evitar estados repetidos. Chama recursivamente a expansão do próximo nó na fila.
% Caso base: para-se a busca quando a fronteira está vazia e não quando se encontra o estado final, pois a busca é apenas para gerar todas as soluções possíveis.
expande([], _) :- !.
% A é o primeiro elemento na fronteira. Faz as operações de andar nas 4 direções a partir de A, adiciona todos esses filhos ao final da fronteira e à lista dos visitados, se eles já não tiverem sido visitados. Adiciona-se às cláusulas o custo de cada um dos filhos de A, com o custo de A + 1 e chama-se a recursão para o resto da fronteira.
expande([A|B], Visitados) :- cima(A, Visitados, Cima), baixo(A, Visitados, Baixo), esq(A, Visitados, Esq), dir(A, Visitados, Dir), concatena(Visitados, Cima, V1), concatena(V1, Baixo, V2), concatena(V2, Esq, V3), concatena(V3, Dir, V4), concatena(B, Cima, L1), concatena(L1, Baixo, L2), concatena(L2, Esq, L3), concatena(L3, Dir, L4), custo(A, C), !, C2 is C + 1, adiciona(Cima, C2), adiciona(Baixo, C2), adiciona(Esq, C2), adiciona(Dir, C2), expande(L4, V4), !.

% concatena(+L1, +L2, -L3) - adiciona L2 ao final de L1, gerando L3. Se L2 for vazia, não adiciona.
concatena(A, [], A) :- !.
concatena(A, B, C) :- append(A, [B], C), !.

% adiciona(+E, +C) - adiciona ao banco de cláusulas e ao arquivo do banco de dados de padrões custo(E, C), que indica que a configuração E tem custo C e escreve no arquivo heuristica(E, C), para ser usada na busca A*.
adiciona([], _) :- !. % se E é vazio, ou seja, um estado que já foi gerado, ele não faz nada
adiciona(L, C) :- assert(custo(L, C)), writef("heuristica("), write(L), writef(", "), write(C), writef(").\n"), !.

% cima(+L1, +V, -L2) - anda com o branco para cima na configuração L1, gerando L2.
% Vê a posição do branco em L1 e armazena em B. Calcula o lado do tabuleiro e armazena em N. LB é a linha aonde o branco está (começando em 0). Para que seja possível andar, LB > 0. CB é a coluna onde está o branco. O elemento a ser trocado com o branco é o que está na mesma coluna, mas 1 linha acima do branco. Calcula-se a posição P do elemento na lista e efetua a troca do branco com o elemento acima dele.
cima(L1, Visitados, L2) :- nth1(B, L1, b), tamanho(L1, T), N is integer(sqrt(T)), LB is (B-1) // N, LB > 0, CB is (B-1) mod N, LP is LB - 1, P is CB + (LP * N) + 1, troca(L1, B, P, L2), not(member(L2, Visitados)), !.
% Se L2 já é um estado pertencente a V (visitados) ou não é possível andar para cima, retorna lista vazia.
cima(_, _, []) :- !.

% baixo(+L1, +V, -L2) - anda com o branco para baixo na configuração L1, gerando L2
% Vê a posição do branco em L1 e armazena em B. Calcula o lado do tabuleiro e armazena em N. LB é a linha aonde o branco está (começando em 0). Para que seja possível andar, LB < (N-1). CB é a coluna onde está o branco. O elemento a ser trocado com o branco é o que está na mesma coluna, mas 1 linha abaixo do branco. Calcula-se a posição P do elemento na lista e efetua a troca do branco com o elemento acima dele.
baixo(L1, Visitados, L2) :- nth1(B, L1, b), tamanho(L1, T), N is integer(sqrt(T)), LB is (B-1) // N, LB < (N-1), CB is (B-1) mod N, LP is LB + 1, P is CB + (LP * N) + 1, troca(L1, B, P, L2), not(member(L2, Visitados)), !.
% Se L2 já é um estado pertencente a V (visitados) ou não é possível andar para baixo, retorna lista vazia
baixo(_, _, []) :- !.

% esq(+L1, +V, -L2) - anda com o branco para esquerda na configuração L1, gerando L2.
% Vê a posição do branco em L1 e armazena em B. Calcula o lado do tabuleiro e armazena em N. CB é a coluna aonde o branco está (começando em 0). Para que seja possível andar, CB > 0. LB é a linha onde está o branco. O elemento a ser trocado com o branco é o que está na mesma linha, mas 1 coluna à esquerda do branco. Calcula-se a posição P do elemento na lista e efetua a troca do branco com o elemento acima dele.
esq(L1, Visitados, L2) :- nth1(B, L1, b), tamanho(L1, T), N is integer(sqrt(T)), CB is (B-1) mod N, CB > 0, LB is (B-1) // N, CP is CB - 1, P is CP + (LB * N) + 1, troca(L1, B, P, L2), not(member(L2, Visitados)), !.
% Se L2 já é um estado pertencente a V (visitados) ou não é possível andar para esquerda, retorna lista vazia
esq(_, _, []) :- !.

% dir(+L1, +V, -L2) - anda com o branco para direita na configuração L1, gerando L2.
% Vê a posição do branco em L1 e armazena em B. Calcula o lado do tabuleiro e armazena em N. CB é a coluna aonde o branco está (começando em 0). Para que seja possível andar, CB < (N-1). LB é a linha onde está o branco. O elemento a ser trocado com o branco é o que está na mesma linha, mas 1 coluna à direita do branco. Calcula-se a posição P do elemento na lista e efetua a troca do branco com o elemento acima dele.
dir(L1, Visitados, L2) :- nth1(B, L1, b), tamanho(L1, T), N is integer(sqrt(T)), CB is (B-1) mod N, CB < (N-1), LB is (B-1) // N, CP is CB + 1, P is CP + (LB * N) + 1, troca(L1, B, P, L2), not(member(L2, Visitados)), !.
% Se L2 já é um estado pertencente a V (visitados) ou não é possível andar para direita, retorna lista vazia.
dir(_, _, []) :- !.

% tamanho(+L, -T) - retorna T que é o número de elementos que L tem
% Caso base: lista vazia tem tamanho 0.
tamanho([], 0) :- !.
% Tamanho da lista é o tamanho da sua cauda + 1.
tamanho([_|Y], T) :- tamanho(Y, T1), T is T1+1, !.

% troca(+L1, +P1, +P2, -L2) - troca em L1 os elementos da posição P1 e P2 entre si, vendo que Ex é o elemento que está na posição Px. Retorna L2 com os elementos trocados
troca(L1, P1, P2, L2) :- nth1(P1, L1, E1), nth1(P2, L1, E2), troca2(L1, P1, E1, P2, E2, 1, L2), !.

% troca2(+L1, +P1, +E1, +P2, +E2, -L2) - troca em L1 os elementos E1 e E2 das posições P1 e P2 respectivamente, entre si.
% Caso base: trocar qualquer par de elementos em qualquer posição em uma lista vazia, retorna lista vazia.
troca2([], _, _, _, _, _, []) :- !.
% Percorre-se a lista, adicionando 1 a 1 os elementos na lista de saída, até chegar na posição P1 ou P2. Chegando em P1, escreve-se E2 na lista de saída e em P2, escreve-se E1.
troca2([A|B], P1, E1, P2, E2, I, [A|L]) :- I \= P1, I \= P2, J is I+1, troca2(B, P1, E1, P2, E2, J, L), !.
troca2([_|B], P1, E1, P2, E2, I, [E1|L]) :- I = P2, J is I+1, troca2(B, P1, E1, P2, E2, J, L), !.
troca2([_|B], P1, E1, P2, E2, I, [E2|L]) :- I = P1, J is I+1, troca2(B, P1, E1, P2, E2, J, L), !.

% quadrado(+N) - retorna true se N é um quadrado perfeito e false caso contrário.
quadrado(N) :- X is sqrt(N), R is truncate(X+0.5), N is R*R.
