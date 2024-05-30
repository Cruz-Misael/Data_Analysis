import gspread

# Importing the auth and default packies from google colab for autentication
from google.colab import auth
auth.authenticate_user()

from google.auth import default
creds, _ = default()
gc = gspread.authorize(creds)

# Opening the sheet1
worksheet = gc.open('Engenharia de Software - Desafio Misael Cruz').sheet1

# Getting the records
rows = worksheet.get_all_records()

# Calculating and writing in the "Situação" column 
for i in range(4, 28):

    # Calculating the average of the "P1", "P2" and "P3" columns
    average = (int(worksheet.cell(i, 4).value) + int(worksheet.cell(i, 5).value) + int(worksheet.cell(i, 6).value)) / 3

    # Calculating the conditions
    if (int(worksheet.cell(i, 3).value) / 60) * 100 > 25:
        worksheet.update('G'+str(i), [["Reprovado por Falta"]])

    elif average < 50:
        worksheet.update('G'+str(i), [["Reprovado por Nota"]])

    elif average < 70:
        worksheet.update('G'+str(i), [["Exame Final"]])

    else:
        worksheet.update('G'+str(i), [["Aprovado"]])


# Calculating and writing on the "Nota para Aprovação Final" column
for i in range(4, 28):

    # Calculating the average of the "P1", "P2" and "P3" columns
    average = (int(worksheet.cell(i, 4).value) + int(worksheet.cell(i, 5).value) + int(worksheet.cell(i, 6).value)) / 3

    # Calculating the conditions
    if worksheet.cell(i, 7).value == 'Exame Final':
        worksheet.update('H'+str(i), [[round(100-(average),0)]])

    else:
        0

# Finish
