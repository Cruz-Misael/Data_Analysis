fila = []
tam = 5

while True:
  print('1 - Inserir caminhão na fila')
  print('2 - Remover caminhão da fila')
  print('3 - Listar a fila de caminhões')
  print('4 - Sair')

  op = int(input("Escolha uma opção:"))
  if op == 1:
    dado = int(input('Qual caminhão deseja inserir?'))
    if len(fila) < 5:
      fila.append(dado)
    else:
      print('Fila cheia! Impossível inserir. ')
  elif op == 2:
    if len(fila) > 0:
      fila.pop(0)
    else:
      print('Fila vazia! Impossível remover. ')
  elif op == 3:
    for item in fila:
      print(item, end=' ')
    print('\n')
  elif op == 4:
    print('Encerrando...')
    break
  else:
    print("Selecione outra opção!\n")