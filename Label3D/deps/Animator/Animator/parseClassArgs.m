function [classArgs, classInds, nonClassArgs] = parseClassArgs(className, varargin)
%% parseClassArgs - Parse arguments specific to a class
% Inputs:
%   className - Name of class whose arguments you wish to parse
%
% Outputs:
%   classArgs - Cell array of class arguments
%   classInds - Logical indices denoting original positions of class
%               arguments. 
% Syntax: 
%   [classArgs, classInds] = parseClassArgs(className, varargin{:})
nameIds = cellfun(@ischar, varargin);
nameIds(2:2:end) = false;
names = varargin(nameIds);
classInds = repelem(contains(names, properties(className)),1,2);
classArgs = varargin(classInds);
nonClassArgs = varargin(~classInds);
end