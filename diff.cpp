#include <iostream>
#include <string>
using std::cout;
using std::cerr;
using std::endl;
using std::string;

int main(int argc, char* argv[])
{
	if (argc < 3)
	{
		cerr << "Not enough arguments!" << endl;
		return 1;
	}
	
	//str1 is the original, patch is the patch to apply
	string str(argv[1]), patch(argv[2]);
	cout << "Applying patch \"" << patch << "\" to string \"" << str << "\"..." << endl;
	enum {NOP, INS, DEL, RPL, LTR} op = NOP;
	for (int i = 0, lpr = 0; i < patch.size() && lpr < str.size(); i++, lpr++) //TODO: Clean up for loop
	{
		cout << "lpr " << lpr << "; i " << i << "; str \"" << str << "\"" << endl;;
		cout << "str[lpr] " << str[lpr] << "; patch[i] " << patch[i] << endl << endl;

		//Get current operation, then apply it for however long is necessary. 
		//i=patch, lpr=str
		bool contd = false;
		switch(patch[i])
		{
			case '/':
				op = NOP;
				lpr++;
				continue; //No need to break, nops are skipped
			case '=':
				op = RPL;
				break;
			case '-':
				op = DEL;
				break;
			case '+':
				op = INS;
				break;
			default:
				contd = true;
				break; //is this needed?
		}
		
		//Use if/else syntax here, a switch statement could be a bit more syntactically hairy.
		if (op == RPL)
		{
			str[lpr] = patch[contd ? i : i + 1];
		}
		else if (op == DEL)
			str.erase(lpr,lpr);
		else if (op == INS)
			str.insert(lpr, 1, patch[contd ? i : i+1]);
	}
	cout << str << endl;
	return 0;
}
