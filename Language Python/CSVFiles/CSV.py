
import csv


with open("CSVFiles/I400.csv", "r") as file:
  file_csv = csv.reader(file, delimiter = ',')

  i400 = {
    'nome' : [],
    'descrição' : [],
    'tamanho' : []
  }

  L=0
  for row in file_csv:
    C=0
    L += 1

    for column in row:
      C += 1

      if C == 3 and L > 1:
        i400['descrição'].append(column)
        tam = column[-6:]
        i400['tamanho'].append(tam)

      elif C == 5 and L > 1:
        i400['nome'].append(column)
      
  for nome, descrição, tamanho in zip(i400['nome'], i400['descrição'], i400['tamanho']):
      print(f'\nNOME: {nome}\nDESCRIÇÃO: {descrição}\nTAMANHO: {tamanho}\n')