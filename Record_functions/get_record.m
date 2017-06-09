function y = get_record(page)

if (nargin == 0); error('This function needs a page file!'); end

y = double(playrec('getRec', page)); % get the data
playrec('delPage');