import { MerkleTree } from 'merkletreejs';
import keccak256 from 'keccak256';
import fs from 'fs';
import csv from 'csv-parser';
import { ethers } from 'ethers'; // Ensure ethers is imported correctly

interface AirdropData {
  address: string;
  amount: string;
}

async function generateMerkleTree() {
  const airdropData: AirdropData[] = [];

  // Read the CSV file and store the data in airdropData array
  fs.createReadStream('airdrop.csv')
    .pipe(csv())
    .on('data', (row) => {
        console.log(row);
      airdropData.push(row);
    })
    .on('end', () => {
      // Generate the Merkle tree leaves
      console.log(airdropData)
      if (airdropData.length === 0) {
        throw new Error('airdropData is empty');
      }
      const leaves = airdropData.forEach((data) => {
        console.log("------------------------------");
        console.log(data);
        const leaf = keccak256(
          ethers.utils.solidityPack(
            ['address', 'uint256'],
            [data.address, ethers.utils.parseUnits(data.amount.trim(), 18)]
          )
        );
        console.log('Leaf for', data.address);
        return leaf;
      });
      const merkleTree = new MerkleTree(leaves, keccak256, { sortPairs: true });
      const merkleRoot = merkleTree.getHexRoot();

      // Output the Merkle root
      console.log('Merkle Root:', merkleRoot);

      // Optionally save the generated proofs for each user
      const proofs = airdropData.map((data) => ({
        address: data.address,
        amount: data.amount,
        proof: merkleTree.getHexProof(
          keccak256(
            ethers.utils.solidityPack(
              ['address', 'uint256'],
              [data.address, ethers.utils.parseUnits(data.amount, 18)]
            )
          )
        )
      }));

      // Save the proofs and Merkle root to a JSON file
      fs.writeFileSync('airdropProofs.json', JSON.stringify({ merkleRoot, proofs }, null, 2));
      console.log('Merkle tree and proofs saved to airdropProofs.json');
    });
}

generateMerkleTree();
