#include <iostream>
#include <string>
using std::cout;
using std::cerr;
using std::endl;
using std::string;

int main(int argc, char* argv[])
{
	/*
	* Simple patch program.
	*
	* Works by first identifying an operator, then applying it to the string.
	* If the nxet character after an operator arg is another character (eg.
	* a letter, the previous operation is applied, eliminating operator
	* redundancy.
	*
	*/

	if (argc < 3)
	{
		cerr << "Not enough arguments!" << endl;
		return 1;
	}
	
	//str1 is the original, patch is the patch to apply
	string str(argv[1]), patch(argv[2]);
	enum {NOP, INS, DEL, RPL, LTR} op = NOP;
	for (int i = 0, lpr = 0; i < patch.size() && lpr < str.size(); i++, lpr++)
	{
		//i=patch, lpr=str
		bool contd = false;
		switch(patch[i]) //Get current operation, or detect a continuation
		{
			case '/':
				op = NOP;
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
		cout << "op " << op << "; contd " << contd << endl << endl;

		//Uses if/else syntax here because a switch statement could be a bit more syntactically hairy.
		if (op == RPL)
		{
			str[lpr] = patch[contd ? i : i + 1];
			if (!contd)
				i++;
		}
		else if (op == DEL)
		{
			str.erase(lpr, 1);
			lpr--;
		}
		else if (op == INS)
		{
			str.insert(lpr, 1, patch[contd ? i : i+1]);
			lpr++;
			if (!contd)
				i++;
		}
	}
	cout << str << endl;
	return 0;
}
