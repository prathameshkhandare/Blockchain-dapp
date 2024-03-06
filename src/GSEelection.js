import React, { useState, useEffect } from "react";
import { Web3Provider } from "@ethersproject/providers";
import { Contract } from "ethers";

const GSElection = ({ address, abi }) => {
    const [contract, setContract] = useState(null);
    const [account, setAccount] = useState(null);
    const [candidates, setCandidates] = useState([]);
    const [selectedCandidate, setSelectedCandidate] = useState("");
    const [hasVoted, setHasVoted] = useState(false);
    const [isConnecting, setIsConnecting] = useState(false);

    useEffect(() => {
        if (!address || !abi) return;
        if (window.ethereum) {
            const provider = new Web3Provider(window.ethereum);
            setContract(new Contract(address, abi, provider));
        } else {
            console.error("MetaMask not installed");
        }
    }, [address, abi]);

    useEffect(() => {
        if (!contract || !account) return;
        const fetchCandidates = async () => {
            const numCandidates = await contract.getNumCandidates();
            const candidatesArray = [];
            for (let i = 0; i < numCandidates; i++) {
                const candidateName = await contract.getCandidateName(i);
                candidatesArray.push({ id: i, name: candidateName });
            }
            setCandidates(candidatesArray);
        };
        fetchCandidates();

        contract.hasUserVoted(account)
            .then(result => {
                setHasVoted(result);
            })
            .catch(error => {
                console.error("Error fetching vote status:", error);
            });
    }, [contract, account]);

    const handleConnect = async () => {
        if (!window.ethereum) {
            console.error("MetaMask not installed");
            return;
        }
        setIsConnecting(true);
        try {
            const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
            setAccount(accounts[0]);
        } catch (error) {
            console.error("Error connecting:", error);
        } finally {
            setIsConnecting(false);
        }
    };

    const handleVote = async () => {
        if (!contract || !account || !selectedCandidate) return;
        try {
            await contract.vote(selectedCandidate);
            setHasVoted(true);
        } catch (error) {
            console.error("Error voting:", error);
        }
    };

    return (
        <div>
            <h1>GSElection</h1>
            <button onClick={handleConnect} disabled={isConnecting || !!account}>
                {isConnecting ? "Connecting..." : "Connect MetaMask"}
            </button>
            {account && (
                <>
                    <h3>Candidates</h3>
                    <ul>
                        {candidates.map(candidate => (
                            <li key={candidate.id}>
                                {candidate.name}
                                {!hasVoted && (
                                    <button onClick={() => setSelectedCandidate(candidate.id)}>
                                        Vote
                                    </button>
                                )}
                            </li>
                        ))}
                    </ul>
                    {hasVoted && <p>You have already voted.</p>}
                </>
            )}
        </div>
    );
};

export default GSElection;
