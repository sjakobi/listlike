{-
Copyright (C) 2007 John Goerzen <jgoerzen@complete.org>

All rights reserved.

For license and copyright information, see the file COPYRIGHT

-}

import Test.QuickCheck
import Test.QuickCheck.Batch
import qualified Data.ByteString as BS
import qualified Data.Array as A
import qualified Data.ByteString.Lazy as BSL
import qualified Data.ListLike as LL
import qualified Data.Map as Map
import qualified Data.Array as A
import qualified Data.Foldable as F
import System.Random
import Test.HUnit
import Text.Printf
import Data.Word
import Data.List
import Data.Monoid
import TestInfrastructure

-- prop_singleton :: (Eq i,LL.ListLike f i) => f -> i -> Bool
--prop_singleton :: (Eq i, LL.ListLike f i, Arbitrary f, Show f, Show i, Arbitrary i) => f -> i -> Bool
prop_singleton f x = (LL.toList $ asTypeOf (LL.singleton x) f) == [x]

prop_empty f = (LL.toList l == []) && (LL.null l) && (LL.length l == 0)
    where l = asTypeOf LL.empty f

prop_tofromlist f = 
    LL.toList f == l && 
    LL.length f == length l &&
    f == (LL.fromList . LL.toList $ f)
    where l = LL.toList f

prop_length f = LL.length f == length (LL.toList f)
prop_cons f i = llcmp (LL.cons i f) (i : (LL.toList f))
prop_append f1 f2 = llcmp (LL.append f1 f2) (LL.toList f1 ++ LL.toList f2)
prop_head f = not (LL.null f) ==> LL.head f == head (LL.toList f)
prop_last f = not (LL.null f) ==> LL.last f == last (LL.toList f)
prop_tail f = not (LL.null f) ==> llcmp (LL.tail f) (tail (LL.toList f))
prop_init f = not (LL.null f) ==> llcmp (LL.init f) (init (LL.toList f))
prop_null f = LL.null f == null (LL.toList f)
prop_length2 f = checkLengths f (LL.toList f)
prop_length3 f1 f2 = llcmp (LL.append f1 f2) (LL.toList f1 ++ LL.toList f2)

prop_map :: forall full item. (TestLL full item, TestLL [item] item) => full -> (item -> item) -> Result
prop_map f func = llcmp llmap (map func (LL.toList f))
    where llmap = asTypeOf (LL.map func f) (LL.toList f)

prop_rigidMap f func = llcmp (LL.rigidMap func f) (map func (LL.toList f))
prop_reverse f = llcmp (LL.reverse f) (reverse (LL.toList f))
prop_intersperse f i = llcmp (LL.intersperse i f) (intersperse i (LL.toList f))

allt = [apf "empty" (t prop_empty),
        apf "length" (t prop_length),
        apf "to/fromList" (t prop_tofromlist),
        apf "singleton" (t prop_singleton),
        apf "cons" (t prop_cons),
        apf "append" (t prop_append),
        apf "head" (t prop_head),
        apf "last" (t prop_last),
        apf "tail" (t prop_tail),
        apf "init" (t prop_init),
        apf "null" (t prop_null),
        apf "length2" (t prop_length2),
        apf "length3" (t prop_length3),
        apf "map" (t prop_map),
        apf "rigidMap" (t prop_rigidMap),
        apf "reverse" (t prop_reverse),
        apf "intersperse" (t prop_intersperse) 
        ]

testh = runTestTT (TestList allt)

main = 
    do printf "Running %d test functions * %d types under test = %d cases\n"
              (length allt) (12::Int) (12 * length allt)
       testh 
       return ()
