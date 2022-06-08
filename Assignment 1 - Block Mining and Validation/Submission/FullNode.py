import time
import pickle
from Block import Block
import os
from hashing import *
import datetime
import json
from util import *
from network import Node
import sys
from datetime import datetime

"""
Establishing connection with backend
"""
class FullNode:
	def __init__(self, id):
		"""
		DO NOT EDIT
		"""
		self.unconfirmed_transactions = []   # Raw TXNs that you will get from the mempool
		self.DIFFICULTY = 5	# Difficulty setting
		self.STUDENT_ID = id # Do not edit, this is your student ID
		self.valid_chain, self.confirmed_transactions = load_valid_chain()  # Your valid chain, all the TXNs in that valid chain
		self.corrupt_transactions = []  # Initialize known corrupt TXNs. To be appended to (by you, later)

	def last_block(self):
		"""
		DO NOT EDIT
		returns last block of the valid chain loaded in memory
		"""
		return self.valid_chain[-1]

	## PART ONE ##

	def mine(self):
		"""
		This function mines a new block and appends it to the current valid chain.
		It firstly loads 5 unconfirmed transactions from the mempool.
		Then verifies them to discard corrupt ones.
		Finally adds them to a dummy block and starts Proof of work
		Once a suitable nonce is found satisfying PoW condition, the block is added to the current validchain.
		"""

		to_add = []
		for txn in self.unconfirmed_transactions:

			if (txn["UTXO_input"] != txn["value_receiver"] + txn["value_sender"]):
				#print("corrupt utxo")
				self.corrupt_transactions.append(txn)
				continue

			elif (VerifySignature(txn["signature_token"], txn["signature"], txn["sender"]) == False ):
				#print("corrupt signature")
				self.corrupt_transactions.append(txn)
				continue

			else:
				to_add.append(txn)
				#print(txn["id"])

		## START CODE HERE ##
		now = datetime.now()
		time_now = now.strftime("%d-%b-%Y (%X)")

		## CREATE BLOCK ##
		new_block = Block(self.last_block().index+1, to_add, time_now, self.compute_hash(self.last_block()), self.STUDENT_ID, nonce=0)

		## POW ##
		valid_hash, valid_nonce = self.proof_of_work(new_block)

		# Add block to valid chain
		new_block.nonce = valid_nonce
		# Save block to physical memory here.
		self.valid_chain.append(new_block)
		save_object(new_block,"valid_chain/block{}.block".format(new_block.index))

	def verify_hash(self, hash):

		for i in range(self.DIFFICULTY):
			if (hash[i] != '0'):
				return False

		return True

	def proof_of_work(self, block):
		"""
		This method performs proof of work on the given block.
		Iterates a nonce value,
		which gives a block hash that satisfies PoW dificulty condition.
		"""
		block.nonce = 0

		while(1):

			computed_hash = self.compute_hash(block)

			if (self.verify_hash(computed_hash) == False):
				block.nonce = block.nonce + 1
				continue
			else:
				break

		# Check for leading zeros according to self.difficulty and add strategy for selecting next nonce to check here
		# Return the hash and the nonce value you found
		return computed_hash,block.nonce


	def compute_hash(self,block):
		"""
		DO NOT EDIT
		Computes the hash of the block by treating all the contents of the block object as a dict.
		"""
		block_string = json.dumps(block.__dict__, sort_keys=True)
		return sha256(block_string.encode()).hexdigest()

	## PART TWO ##

	def validate_pending_chains(self):
		"""
		DO NOT EDIT
		This method loads pending chains from the 'pending_chains' folder.
		It then calls verify_chain method on each chain performing a series of validity checks
		if all the tests pass, it replaces the current valid chain with pending chain and saves it in valid chain folder.
		"""
		self.valid_chain, self.confirmed_transactions = load_valid_chain()
		MAIN_DIR = "pending_chains"
		subdirectories = [name for name in os.listdir(MAIN_DIR) if os.path.isdir(os.path.join(MAIN_DIR, name))]
		for directory in subdirectories:
			temp_chain = []
			DIR = MAIN_DIR + "/" + directory
			block_indexes = [name for name in os.listdir(DIR) if os.path.isfile(os.path.join(DIR, name))]
			block_indexes.sort()
			for block_index in block_indexes:
				try:
					with open(DIR+'/{}'.format(block_index), 'rb') as inp:
						block = pickle.load(inp)
						temp_chain.append(block)
				except:
					pass
			last_block_index=temp_chain[0].index-1
			last_block_hash=self.compute_hash(self.valid_chain[last_block_index])
			current_longest=self.valid_chain[:last_block_index+1]+temp_chain
			if (self.verify_chain(current_longest, temp_chain, last_block_hash)):
				print("Replaced valid chain with chain from", directory)
				self.valid_chain = current_longest
				save_chain(current_longest)
				self.valid_chain, self.confirmed_transactions = load_valid_chain()
			else:
				print("Rejected chain from", directory)
			pc_del_command="rm -rf "+DIR
			os.system(pc_del_command)

	def verify_chain(self, current_longest,temp_chain,last_block_hash):

		"""
		This method performs the following validity checks on the input temp, or pending, chain.
			- whether length of temp_chain is greater than current valid chain (consider checking indexes)
			- whether previous hashes of blocks correspond to calculated block hashes of previous blocks
			- whether the difficulty setting has been achieved
			- whether each transaction is valid
				- no two or more transactions have same id
				- the signature in transaction is valid
				- The UTXO calculation is correct (input = sum of outputs)
		Return True if all is good
		Return False if failed any one of the checks

		temp_chain: your peer's blocks/chain that is being tested
		current_longest: your valid chain + temp_chain/new blocks your peer mined
		last_block_hash: the hash of your last block

		"""

		# Checking the previous hash of the new block against your last block. This is done for you
		previous_hash=last_block_hash
		if temp_chain[0].previous_hash!=last_block_hash:
			print("Bad previous hash")
			return False

		## Add code for other checks here
		## checking temp_chain
		if (self.chains_validating(temp_chain, last_block_hash) == False):
			#print("wrong temp_chain")
			return False

		## checking current_longest
		transactions_list = []
		for block in current_longest:
			if (block.miner == "Satoshi"):
				continue

			for txn in block.transactions:

				if (txn["UTXO_input"] != txn["value_receiver"] + txn["value_sender"]):
					#print("corrupt utxo")
					return False

				if (VerifySignature(txn["signature_token"], txn["signature"], txn["sender"]) == False ):
					#print("corrupt signature")
					return False

				transactions_list.append(txn["id"])

		if (len(transactions_list) != len(set(transactions_list))):
			#print("duplicates")
			return False

		return True

	def chains_validating(self, chain, last_block_hash):

		## 3.1 validating hash
		for block in chain:

			if (self.verify_hash(self.compute_hash(block)) == False):
				#print("hash not valid")
				return False

		## 3.2 Check number of transactions
		for block in chain:

			if not (len(block.transactions) <6 and len(block.transactions) >0):
				#print("incorrect number of transactions")
				return False

		## 3.3 Check Previous Hashes
		for block in chain:

			if block.previous_hash != last_block_hash:
				#print("Bad previous hash1")
				return False
			else:
				last_block_hash = self.compute_hash(block)

		## 3.4 Validate Individual transactions
		transactions_list = []
		for block in chain:

			for txn in block.transactions:

				if (txn["UTXO_input"] != txn["value_receiver"] + txn["value_sender"]):
					#print("corrupt utxo")
					return False

				if (VerifySignature(txn["signature_token"], txn["signature"], txn["sender"]) == False ):
					#print("corrupt signature")
					return False

				transactions_list.append(txn["id"])

		if (len(transactions_list) != len(set(transactions_list))):
			#print("duplicates")
			return False

		return True


	def print_chain(self):
		"""
		DO NOT EDIT
		Prints the current valid chain in the terminal.
		"""
		self.valid_chain, self.confirmed_transactions = load_valid_chain()
		for block in self.valid_chain:
			print ("***************************")
			print("Block index # {}".format(block.index))

			for trans in block.transactions:

				print("Sender: {}".format(trans["sender"]['key']) )
				print("Receiver: {}".format(trans['receiver']['key']))
				print("Token: {}".format(trans["signature_token"]) )
				print("UTXO input: {}".format(trans["UTXO_input"]))
				print("Sender received: {}".format(trans["value_sender"]))
				print("Receiver received: {}".format(trans["value_receiver"]))
				print("ID: {}".format(trans["id"]))
			print("---------------------------")
			print("nonce: {}".format(block.nonce) )
			print("previous_hash: {}".format(block.previous_hash) )
			print('hash: {}'.format(self.compute_hash(block)))
			print('Miner: {}'.format(block.miner))
			print ("***************************")
			print("")

"""
DO NOT EDIT ANYTHING BELOW
"""
def commands():
	"""
	CLI to access the Blockchain class
	"""
	print("\"mine\" to mine")
	print("\"validate\" to validate pending chains")
	print("\"ra\" to request all chains")
	print("\"rl\" to request longest chain")
	print("\"send state\" to send your current state to the backend")
	print("\"print\" to print saved chain")
	print("\"exit\" to exit")
	print("\"help\" to see available commands")

if __name__ == "__main__":
	"""
	Establishing connection with backend
	"""
	host='localhost'
	backend_p=3210
	backend=(host,backend_p)
	try:
		id= os.getlogin()[1:]
		port = int(id[0:2]+id[-3:])
	except:
		print("Invalid ID")
		sys.exit()
	"""
	Node connection setup
	"""
	node=Node(host,port,backend, id)
	node.start_connection()
	commands()
	N = FullNode(id)
	N.valid_chain, N.confirmed_transactions = load_valid_chain()
	N.unconfirmed_transactions = load_unconfirmed_transactions(N.confirmed_transactions, N.corrupt_transactions)
	node.send_states()
	while True:

		args=input(">> ")
		N.valid_chain, N.confirmed_transactions = load_valid_chain()
		N.unconfirmed_transactions = load_unconfirmed_transactions(N.confirmed_transactions, N.corrupt_transactions)

		"""
		CLI commands are parsed and respective functions are called.
		"""
		if args=="mine":
			N.mine()
		elif args=="validate":
			N.validate_pending_chains()
		elif args=="rl":
			node.request(N.valid_chain, "longest")
		elif args=="ra":
			node.request(N.valid_chain, "all")
		elif args=="send state":
			node.send_states()
		elif args=="print":
			N.print_chain()
		elif args=="help":
			commands()
		elif args=="exit":
			node.disconnect()
			break
