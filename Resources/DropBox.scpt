FasdUAS 1.101.10   ��   ��    k             i         I     �� 	 

�� .facofgetnull���     alis 	 o      ���� 0 dropbox DropBox 
 �� ��
�� 
flst  o      ���� 0 droppedfiles DroppedFiles��    k     �       l     ��������  ��  ��        l     ��  ��    T Nset scriptPath to (path to Folder Action scripts as Unicode text) & "tmp.scpt"     �   � s e t   s c r i p t P a t h   t o   ( p a t h   t o   F o l d e r   A c t i o n   s c r i p t s   a s   U n i c o d e   t e x t )   &   " t m p . s c p t "      l     ��������  ��  ��        l     ��  ��    ) # Get the comment from Punakea prefs     �   F   G e t   t h e   c o m m e n t   f r o m   P u n a k e a   p r e f s      O         k    ~      !   Q    . " #�� " k    % $ $  % & % r     ' ( ' c     ) * ) l    +���� + b     , - , l    .���� . c     / 0 / l    1���� 1 I   �� 2 3
�� .earsffdralis        afdr 2 1    
��
�� 
dlib 3 �� 4��
�� 
from 4 1    ��
�� 
fldu��  ��  ��   0 m    ��
�� 
TEXT��  ��   - m     5 5 � 6 6 N P r e f e r e n c e s : e u . n u d g e n u d g e . p u n a k e a . p l i s t��  ��   * m    ��
�� 
alis ( o      ���� 0 	plistfile 	pListFile &  7�� 7 r    % 8 9 8 n    # : ; : 1   ! #��
�� 
pcnt ; 4    !�� <
�� 
plif < l     =���� = c      > ? > o    ���� 0 	plistfile 	pListFile ? m    ��
�� 
utxt��  ��   9 o      ���� 0 plist pList��   # R      ������
�� .ascrerr ****      � ****��  ��  ��   !  @ A @ l  / /��������  ��  ��   A  B C B r   / 2 D E D m   / 0 F F � G G   # # # b e g i n _ t a g s # # # E o      ���� 0 
thecomment 
theComment C  H I H l  3 3��������  ��  ��   I  J K J Q   3 v L M N L k   6 g O O  P Q P r   6 @ R S R n   6 > T U T 1   : >��
�� 
valL U n   6 : V W V 4   7 :�� X
�� 
plii X m   8 9 Y Y � Z Z 0 M a n a g e F i l e s . D r o p B o x . T a g s W o   6 7���� 0 plist pList S o      ���� 0 tags   Q  [ \ [ l  A A��������  ��  ��   \  ]�� ] X   A g ^�� _ ^ r   U b ` a ` b   U ` b c b b   U \ d e d b   U Z f g f o   U V���� 0 
thecomment 
theComment g m   V Y h h � i i  @ e o   Z [���� 0 tag   c m   \ _ j j � k k  ; a o      ���� 0 
thecomment 
theComment�� 0 tag   _ o   D E���� 0 tags  ��   M R      ������
�� .ascrerr ****      � ****��  ��   N r   o v l m l b   o t n o n o   o p���� 0 
thecomment 
theComment o m   p s p p � q q  @ u n t a g g e d ; m o      ���� 0 
thecomment 
theComment K  r s r l  w w��������  ��  ��   s  t�� t r   w ~ u v u b   w | w x w o   w x���� 0 
thecomment 
theComment x m   x { y y � z z  # # # e n d _ t a g s # # # v o      ���� 0 
thecomment 
theComment��    m      { {�                                                                                  sevs   alis    t  Mac                        Ò��H+     �System Events.app                                                ��c        ����  	                CoreServices    Ò��      ��C       �   Q   P  1Mac:System:Library:CoreServices:System Events.app   $  S y s t e m   E v e n t s . a p p    M a c  -System/Library/CoreServices/System Events.app   / ��     | } | l  � ���������  ��  ��   }  ~  ~ l  � ��� � ���   � %  Write comment on dropped files    � � � � >   W r i t e   c o m m e n t   o n   d r o p p e d   f i l e s   ��� � X   � � ��� � � k   � � � �  � � � r   � � � � � c   � � � � � o   � ����� 0 afile aFile � m   � ���
�� 
TEXT � o      ���� 0 f   �  � � � l  � ���������  ��  ��   �  � � � Q   � � � ��� � k   � � � �  � � � l  � ��� � ���   � &  tell application "System Events"    � � � � @ t e l l   a p p l i c a t i o n   " S y s t e m   E v e n t s " �  � � � l  � ��� � ���   � 6 0	attach action to folder f using file scriptPath    � � � � ` 	 a t t a c h   a c t i o n   t o   f o l d e r   f   u s i n g   f i l e   s c r i p t P a t h �  � � � l  � ��� � ���   �  end tell    � � � �  e n d   t e l l �  � � � l  � ���������  ��  ��   �  ��� � O   � � � � � r   � � � � � o   � ����� 0 
thecomment 
theComment � n       � � � 1   � ���
�� 
comt � 4   � ��� �
�� 
alis � o   � ����� 0 f   � m   � � � ��                                                                                  MACS   alis    V  Mac                        Ò��H+     �
Finder.app                                                       s��Z߄        ����  	                CoreServices    Ò��      �Z�t       �   Q   P  *Mac:System:Library:CoreServices:Finder.app   
 F i n d e r . a p p    M a c  &System/Library/CoreServices/Finder.app  / ��  ��   � R      ������
�� .ascrerr ****      � ****��  ��  ��   �  ��� � l  � ���������  ��  ��  ��  �� 0 afile aFile � o   � ����� 0 droppedfiles DroppedFiles��     ��� � l     ��������  ��  ��  ��       �� � ���   � ��
�� .facofgetnull���     alis � �� ���� � ���
�� .facofgetnull���     alis�� 0 dropbox DropBox�� ������
�� 
flst�� 0 droppedfiles DroppedFiles��   � 	�������������������� 0 dropbox DropBox�� 0 droppedfiles DroppedFiles�� 0 	plistfile 	pListFile�� 0 plist pList�� 0 
thecomment 
theComment�� 0 tags  �� 0 tag  �� 0 afile aFile�� 0 f   �  {��������~ 5�}�|�{�z�y�x F�w Y�v�u�t�s h j p y ��r
�� 
dlib
�� 
from
�� 
fldu
� .earsffdralis        afdr
�~ 
TEXT
�} 
alis
�| 
plif
�{ 
utxt
�z 
pcnt�y  �x  
�w 
plii
�v 
valL
�u 
kocl
�t 
cobj
�s .corecnte****       ****
�r 
comt�� �� | #*�,�*�,l �&�%�&E�O*��&/�,E�W X  hO�E�O 6���/a ,E�O %�[a a l kh �a %�%a %E�[OY��W X  �a %E�O�a %E�UO =�[a a l kh ��&E�O a  �*�/a ,FUW X  hOP[OY��ascr  ��ޭ