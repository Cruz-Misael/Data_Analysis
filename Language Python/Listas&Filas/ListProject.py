
#Create each element in the list
class ElementoDaListaSimples:

#Class initialization constructor
    def __init__(self, dado, cor):
        self.dado = dado
        self.cor = cor
        self.tam = 10
        self.proximo = None

#__repr__ is used to create the way the object is displayed outside of the print function
    def __repr__(self):
        return self.dado and self.cor
    
#Create a simple linked list
class ListaEncadeadaSimples:
    def __init__(self, nodos=None):
        self.head = None
        if nodos is not None:
            nodo = ElementoDaListaSimples(dado=nodos.pop(0), cor=nodos.pop(0))
            self.head = nodo
            for elem in nodos:
                nodo.proximo = ElementoDaListaSimples(dado=elem, cor=elem)
                nodo = nodo.proximo

    def __repr__(self):
        nodo = self.head
        nodos = []
        while nodo is not None:
            nodos.append(nodo.dado)
            nodo = nodo.proximo
        nodos.append("None")
        return " -> ".join(nodos)

#Scan the list
    def __iter__(self):
        nodo = self.head
        while nodo is not None:
            yield nodo
            nodo = nodo.proximo

    def inserirPrioridade(self, nodo):
        nodo.proximo = self.head
        self.head = nodo

    def InserirNoFinal(self, nodo):
        if self.head is None:
            self.head = nodo
            return
        nodo_atual = self.head
        while nodo_atual.proximo != None:
            nodo_atual = nodo_atual.proximo
        nodo_atual.proximo = nodo
        return

    def Inserir(self, dado, cor):
        nodo = ElementoDaListaSimples(dado, cor)
        if self.head is None:
            self.head = nodo
            return 0
        else:
            if nodo.cor == "V":
                self.InserirNoFinal(nodo)
            else:
                self.inserirPrioridade(nodo)
                return

    def imprimir(self):
        temp = self.head
        while temp:
            print(f"{temp.dado} {temp.cor}")
            temp = temp.proximo



Lista = ListaEncadeadaSimples()

while True:
  print('1 - Inserir na lista')
  print('2 - Imprimir a lista')
  print('3 - Sair')

  op = int(input("Escolha uma opção:"))
  if op == 1:
    dado1 = input('Qual número deseja inserir?')
    cor1 = input('Qual cor deseja inserir?')
    Lista.Inserir(dado1, cor1)
  elif op == 2:
    Lista.imprimir()
  elif op == 3:
    print('Encerrando...')
    break
  else:
    print("Selecione outra opção!\n")
