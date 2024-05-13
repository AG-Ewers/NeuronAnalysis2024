function [per_neuron_results] = summarizeResults(per_neuron_results, Classified_processes, pix_size, k, error_code)
%Summarize_per_neuron summarizes relevant parameters for individual neurons
%   Input: existing matrix of results, Classified processes, pixel size,
%   iteration, error_code ('all fine', 'excluded', 'no soma', 'no neurites'
%   Output: appended matrix of results
    
    per_neuron_results(k,1) = {Classified_processes.Image_name}; 

    % check if any known problem is detected
    switch error_code
        case 'all fine'
            per_neuron_results(k,2) = {Classified_processes.TimestampStart};
            per_neuron_results(k,3) = {Classified_processes.TimestampEnd};
   
            % total_neurite_length (as measured from segmented skeleton!)
            sklI_noSoma = Classified_processes.Initial_skeleton .* (~ bwmorph(Classified_processes.cBody,'thin',1));
            segmentedStruct = regionprops(bwlabel(sklI_noSoma), 'PerimeterOld');
            per_neuron_results(k,4) = {pix_size * sum([segmentedStruct(:).PerimeterOld])/2};
            
            % soma_size 
            per_neuron_results(k,5) = {pix_size * pix_size * nnz(Classified_processes.cBody)};
            
            % axon_length 
            per_neuron_results(k,6) = {pix_size * regionprops(Classified_processes.Axon{1},'PerimeterOld').PerimeterOld / 2};

            % prim_branch_points
            prim_branch_points = size(Classified_processes.AxonBranches{2});
            per_neuron_results(k,7) = {prim_branch_points(1)};
            
            % prim_branch_length
            %per_neuron_results(k,8) = {pix_size * nnz(cell2mat(Classified_processes.AxonBranches{2}))};
            
            primaryStruct = regionprops(bwlabel(cell2mat(Classified_processes.AxonBranches{2})),'PerimeterOld');
            per_neuron_results(k,8) = {pix_size * sum([primaryStruct(:).PerimeterOld])/2};
            
            % sec_branch_points
            sec_branch_points = size(Classified_processes.AxonBranches{3});
            per_neuron_results(k,9) = {sec_branch_points(1)};    
            % sec_branch_length
            %per_neuron_results(k,10) = {pix_size * nnz(cell2mat(Classified_processes.AxonBranches{3}))};

            secStruct = regionprops(bwlabel(cell2mat(Classified_processes.AxonBranches{3})),'PerimeterOld');
            per_neuron_results(k,10) = {pix_size * sum([secStruct(:).PerimeterOld])/2};
            
            %tert_branch_points
            tert_branch_points = size(Classified_processes.AxonBranches{4});
            per_neuron_results(k,11) = {tert_branch_points(1)};
            %tert_branch_length
            %per_neuron_results(k,12) = {pix_size * nnz(cell2mat(Classified_processes.AxonBranches{4}))};
            
            tertStruct = regionprops(bwlabel(cell2mat(Classified_processes.AxonBranches{4})),'PerimeterOld');
            per_neuron_results(k,12) = {pix_size * sum([tertStruct(:).PerimeterOld])/2};
            
            % Axon branches
            axon_branch_points = 0;
            axon_branch_length = 0;
            for l = 2:size(Classified_processes.AxonBranches)
                num = size(Classified_processes.AxonBranches{l});
                axon_branch_points = axon_branch_points + num(1);
                %len = nnz(cell2mat(Classified_processes.AxonBranches{l}));
                tempStruct = regionprops(bwlabel(cell2mat(Classified_processes.AxonBranches{l})),'PerimeterOld');
                len = pix_size * sum([tempStruct(:).PerimeterOld])/2;
                axon_branch_length = axon_branch_length + len;
            end

            per_neuron_results(k,13) = {axon_branch_points};
            % axon_branch_length
            per_neuron_results(k,14) = {axon_branch_length};


            % dendrite_number
            dendrite_number = size(Classified_processes.Neurites);
            per_neuron_results(k,15) = {dendrite_number(1)};
            
            % dendrite_length
            dendrStruct = regionprops(cell2mat(Classified_processes.Neurites),'PerimeterOld');
            per_neuron_results(k,16) = {pix_size * sum([dendrStruct(:).PerimeterOld])/2};
            % per_neuron_results(k,16) = {pix_size * nnz(cell2mat(Classified_processes.Neurites))};

            % Dendrite branches
            dendrite_branch_points = 0;
            dendrite_branch_length = 0;
            for l = 2:size(Classified_processes.NeuriteBranches)
                num = size(Classified_processes.NeuriteBranches{l});
                dendrite_branch_points = dendrite_branch_points + num(1);
                %len = nnz(cell2mat(Classified_processes.NeuriteBranches{l}));
                tempStruct2 = regionprops(bwlabel(cell2mat(Classified_processes.NeuriteBranches{l})),'PerimeterOld');
                len = pix_size * sum([tempStruct2(:).PerimeterOld])/2;
                dendrite_branch_length = dendrite_branch_length + len;
            end

            per_neuron_results(k,17) = {dendrite_branch_points};
            %dendrite_branch_length = 
            per_neuron_results(k,18) = {dendrite_branch_length};
            
            % Total axon length
            per_neuron_results(k,19) = { per_neuron_results{k,6} +  per_neuron_results{k,14}};

            % No comment
            per_neuron_results(k,20) = {''};
            
        case 'excluded'
            % how is k dealt with here? or with the others?
            per_neuron_results(k,2) = {'NA'};
            per_neuron_results(k,3) = {'NA'};
            per_neuron_results(k,4) = {NaN};
            per_neuron_results(k,5) = {NaN};
            per_neuron_results(k,6) = {NaN};
            per_neuron_results(k,7) = {NaN};
            per_neuron_results(k,8) = {NaN};
            per_neuron_results(k,9) = {NaN};
            per_neuron_results(k,10) = {NaN};
            per_neuron_results(k,11) = {NaN};
            per_neuron_results(k,12) = {NaN};
            per_neuron_results(k,13) = {NaN};
            per_neuron_results(k,14) = {NaN};
            per_neuron_results(k,15) = {NaN};
            per_neuron_results(k,16) = {NaN};
            per_neuron_results(k,17) = {NaN};
            per_neuron_results(k,18) = {NaN};
            per_neuron_results(k,19) = {NaN};
            per_neuron_results(k,20) = {'Excluded after segmentation'};
           
        case 'no soma'
            % no soma detected -> nothing summarized
            per_neuron_results(k,2) = {Classified_processes.TimestampStart};
            per_neuron_results(k,3) = {Classified_processes.TimestampEnd};
            per_neuron_results(k,4) = {NaN};
            per_neuron_results(k,5) = {NaN};
            per_neuron_results(k,6) = {NaN};
            per_neuron_results(k,7) = {NaN};
            per_neuron_results(k,8) = {NaN};
            per_neuron_results(k,9) = {NaN};
            per_neuron_results(k,10) = {NaN};
            per_neuron_results(k,11) = {NaN};
            per_neuron_results(k,12) = {NaN};
            per_neuron_results(k,13) = {NaN};
            per_neuron_results(k,14) = {NaN};
            per_neuron_results(k,15) = {NaN};
            per_neuron_results(k,16) = {NaN};
            per_neuron_results(k,17) = {NaN};
            per_neuron_results(k,18) = {NaN};
            per_neuron_results(k,19) = {NaN};
            per_neuron_results(k,20) = {'No soma detected'};
            
        case 'no neurites'
            per_neuron_results(k,2) = {Classified_processes.TimestampStart};
            per_neuron_results(k,3) = {Classified_processes.TimestampEnd};

            % total_neurite_length (does not depend on classification)
            sklI_noSoma = Classified_processes.Initial_skeleton .* (~ bwmorph(Classified_processes.cBody,'thin',1));
            segmentedStruct = regionprops(bwlabel(sklI_noSoma), 'PerimeterOld');
            per_neuron_results(k,4) = {pix_size * sum([segmentedStruct(:).PerimeterOld])/2};
            
            % soma_size 
            per_neuron_results(k,5) = {pix_size * pix_size * nnz(Classified_processes.cBody)};
            
            % the rest is not summarized
            per_neuron_results(k,6) = {NaN};
            per_neuron_results(k,7) = {NaN};
            per_neuron_results(k,8) = {NaN};
            per_neuron_results(k,9) = {NaN};
            per_neuron_results(k,10) = {NaN};
            per_neuron_results(k,11) = {NaN};
            per_neuron_results(k,12) = {NaN};
            per_neuron_results(k,13) = {NaN};
            per_neuron_results(k,14) = {NaN};
            per_neuron_results(k,15) = {NaN};
            per_neuron_results(k,16) = {NaN};
            per_neuron_results(k,17) = {NaN};
            per_neuron_results(k,18) = {NaN};
            per_neuron_results(k,19) = {NaN};
            per_neuron_results(k,20) = {'No neurites detected'}; 
    end
        
    % Headers  
    header = {'NeuronIndex', 'TimeStart', 'TimeEnd',  'TotalNeuriteLengthEstimate', 'SomaSize' , 'PrimaryAxonLength', 'PrimBranchNum' , 'PrimBranchLength', 'SecBranchNum' , 'SecBranchLength', 'TertBranchNum' , 'TertBranchLength', 'AxonBranchPoints', 'AxonBranchLength', 'DendriteNum' , 'TotalDendriteLength', 'DendBranchNum' , 'DendBranchLen', 'TotalAxonLength','Comment'};
    per_neuron_results.Properties.VariableNames = header;

end

