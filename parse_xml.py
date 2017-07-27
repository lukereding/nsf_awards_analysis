import os
import bs4
import csv

def e_8(s):
    return s.encode('utf-8')

os.chdir('./data')

all_files = [file for file in os.listdir('.') if file.endswith(".xml")]

print("total number of files: {}".format(len(all_files)))

with open('../out.csv', 'w') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow( ('file_name', 'directorate', 'division', 'title', 'institution', 'amount', 'grant type', 'abstract', 'date_start', 'date_end', 'program_officer', 'investigators', 'roles', 'number_pis') )

    for i, file in enumerate(all_files):
        try:
            print(i)
            # read in file
            file_name = file
            handler = open(file).read()
            soup = bs4.BeautifulSoup(handler, 'xml')

            # record a bunch of stuff about the grant
            directorate = e_8(soup.Directorate.LongName.text)
            division = e_8(soup.Division.LongName.text)
            title = e_8(soup.AwardTitle.text)

            institution = e_8(soup.Institution.Name.text)

            amount = e_8(soup.Award.AwardAmount.text)
            grant_type = e_8(soup.Award.AwardInstrument.Value.text)
            abstract = e_8(soup.Award.AbstractNarration.text)

            # need to parse these date:
            date_end = e_8(soup.AwardExpirationDate.text)
            date_start = e_8(soup.AwardEffectiveDate.text)

            program_officer = e_8(soup.ProgramOfficer.text)

            investigators = list()
            roles = list()
            for investigator in soup.find_all("Investigator"):
                name = e_8(soup.Investigator.FirstName.text) + b" " + e_8(soup.Investigator.LastName.text)
                if name not in investigators:
                    investigators.append(name)
                    roles.append(e_8(soup.Investigator.RoleCode.text))

            number_pis = len(set(investigators))

            try:
                writer.writerow( (file_name, directorate, division, title, institution, amount, grant_type, abstract, date_start, date_end, program_officer, investigators, roles, number_pis) )
            except:
                writer.writerow( ('NA', 'NA','NA','NA','NA','NA','NA','NA','NA','NA','NA','NA') )
                print("problem writing the csv row")
        except:
            # this occured three times in the whole dataset
            print("problem parsing the XML file: {}".format(file))

        if i % 100 == 0:
            print("on the {}th file".format(i))
    csvfile.close()
