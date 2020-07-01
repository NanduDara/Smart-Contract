pragma solidity ^0.4.17;

contract Contract_Govt {
    
    //Government Lender deploys the smart contract with the tender details (i.e., time, cost, and support)
    address public govt_lender;
    uint public lender_time; uint public lender_cost; uint public lender_support;
    
    //This constructor will be called first when this contract is deployed and stores the values in respective variables
    //constructor(uint time, uint cost, uint support) public {
    function Contract_Govt(uint time, uint cost, uint support) public {
        govt_lender = msg.sender;
        lender_time = time;
        lender_cost = cost;
        lender_support = support;
    }
    
    //Any number of constructors can enter into the contract with providing the tender details (i.e., time, cost, and support)
    address[] public cons;
    uint[] public cons_time; uint[] public cons_cost; uint[] public cons_support;
    
    //constructor will be entered into the network through this enter function
    function enter(uint time, uint cost, uint support) public payable {
        require(msg.value > 1 ether); //We make sure constructor have minimum ethers to perform the operations in the samrt contract, by collecting some enetry fee
        msg.sender.transfer(this.balance); //We return back the enetry fee to that constructor after verifying that constrcutor can perfrom all the operations in contract 
        cons.push(msg.sender);
        msg.sender.transfer(this.balance); 
        cons_time.push(time);
        cons_cost.push(cost);
        cons_support.push(support);
    }
    
    //Algorithm 1 (Cost Optimization among Government Lenders)
    function first_auction(uint[] memory c_time, uint[] memory c_cost, uint[] memory c_support) public payable {
        //Iteratively bringes the lender time value closer to median of times values given by group of constructors after sorting(increasing order)
        uint[] memory s_ctime = sort(c_time);
        uint length1 = s_ctime.length;
        //Picks the median element
        uint midelement1 = s_ctime[length1/2];
        
        while(lender_time-midelement1 != 0){
            lender_time++;
        }
        
        //Iteratively bringes the lender time value closer to median of times values given by group of constructors after sorting(increasing order)
        uint[] memory s_ccost = sort(c_cost);
        uint length2 = s_ccost.length;
        //Picks the median element
        uint midelement2 = s_ccost[length2/2];
        
        while(lender_cost-midelement2 != 0){
            lender_cost++;
        }
        
        //Iteratively bringes the lender time value closer to median of times values given by group of constructors after sorting(increasing order)
        uint[] memory s_csupport = sort(c_support);
        uint length3 = s_csupport.length;
        //Picks the median element
        uint midelement3 = s_csupport[length3/2];
        
        while(lender_support-midelement3 != 0){
            lender_support--;
        }
    }
    
    //Intially win counts of all the constructors are set to 0
    uint[] public win_count;
    //cumulative cost of all the constructors 
    uint[] public rho;
    
    //Algorithm 2 (Cost Optimization among Constructors)
    function second_auction(uint[] c_time, uint[] c_cost, uint[] c_support) public payable {
        
        uint l = c_time.length;
        set_values(l);
        uint iter = 4;
        //Initially we consider 4 iterations
        for(uint i=0;i<iter;i++) {
            
            //The cumulative cost is calculated for all the constructors
            for(uint x=0;x<l;x++) {
                rho[x] = c_time[x]+c_cost[x]+c_support[x];
            }
            
            //sorted cumulative cost array is stored
            uint[] memory s_rho = sort(rho);
            uint min_rho = s_rho[0];
            uint index = search(rho, min_rho);
            //win count of constructor having the minimum cumulative cost is increased by 1
            win_count[index] = win_count[index]+1;
        
            //The constructors that does not win will change their tender detailes (time, cost, support)
            for(uint k=0;k<l;k++) {
                if(k != index) {
                    c_time[k] = c_time[k] - 1;
                    c_cost[k] = c_cost[k] - 1;
                    c_support[k] = c_support[k] + 1;
                }
            }
        }
        
    }
    
    //The constructor that having maximum win_count will be declared as winner and allocated with the tender
    function find_winner() public view returns (address) {
        uint len = win_count.length;
        uint win = win_count[len-1];
        uint winner = search(win_count, win);
        return cons[winner];
    }
    
    //This function will initially set the values of win count and cumulative cost of all constructors to 0
    function set_values(uint len) internal {
        for(uint a=0;a<len;a++) {
            rho.push(0);
            win_count.push(0);
        }
    }
    
    //This function search for the given element in the given array and returns the index of the element in the array 
    function search(uint[] memory _rho, uint min_rho) public pure returns (uint) {
        uint len = _rho.length;
        uint ind = 0;
        for(uint i=0;i<len;i++){
            if(min_rho == _rho[i]) {
                ind = i;
                break;
            }
        }
        return ind;
    }
    
    //Sorts the array using quick sort algorithm
    function sort(uint[] memory data) public payable returns (uint[]) {
       quickSort(data, int(0), int(data.length - 1));
       return data;
    }
    
    //This function implements Quick Sort algorithm
    function quickSort(uint[] arr, int left, int right) internal{
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }
}