import bleu
import edit_distance as e

r1 = 'I have a pen but do not have an apple'.split()
c1 = 'I have a pen but do not have an apple'.split()
r2 = 'I have a pen but do not have an apple'.split()
c2 = 'I have a pen but not have apples'.split()
ref = [r1, r2]
cand = [c1, c2]

print(f'Reference: {r2} \n Candidate: {c2} \n BLEU: {bleu.bleu_sentence(r1, c1, 4)}\n')
print(f'BLEU for corpus: {bleu.bleu_corpus(ref, cand, 4)}\n')
print(f'BLEU for each: {bleu.bleu_points(ref, cand, 4)}\n')

print(f'Reference: {r2} \n Candidate: {c2} \n Edit Distance: {e.edit_distance_sentence(r2, c2)}\n')
print(f'Edit Distance for corpus: {e.edit_distance_corpus(ref, cand)}\n')
print(f'Edit Distance for each: {e.edit_distance_points(ref, cand)}\n')
